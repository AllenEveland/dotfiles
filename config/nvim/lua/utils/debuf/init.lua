local api = vim.api
local cmd = vim.cmd
local fn = vim.fn
local bo = vim.bo

if fn.has('nvim-0.10') == 0 then
    vim.notify('debuf.nvim requires Neovim 0.10 or later', vim.log.levels.ERROR)
    return
end

local M = {}

local function bufname(bufnr)
    local name = api.nvim_buf_get_name(bufnr)
    return name ~= '' and name or '[No Name]'
end

local function char_prompt(text, choices)
    local choice = fn.confirm(text, table.concat(choices, '\n'), '', 'Q')
    if choice == 0 then
        return 'C'
    end
    return choices[choice]:match('&?(%a)')
end

local function buf_kill(target_buffers, switchable_buffers, force, wipeout)
    local buf_is_deleted = {}
    for _, v in ipairs(target_buffers) do
        buf_is_deleted[v] = true
    end

    if not force then
        for bufnr in pairs(buf_is_deleted) do
            if bo[bufnr].modified then
                local choice = char_prompt(
                    ('No write since last change for buffer %d (%s).'):format(bufnr, bufname(bufnr)),
                    { '&Save', '&Ignore', '&Cancel' }
                )

                if choice == 's' or choice == 'S' then
                    api.nvim_buf_call(bufnr, function() cmd.write() end)
                elseif choice ~= 'i' and choice ~= 'I' then
                    buf_is_deleted[bufnr] = nil
                end
            elseif bo[bufnr].buftype == 'terminal'
                and fn.jobwait({ bo[bufnr].channel }, 0)[1] == -1 then
                local choice = char_prompt(
                    ('Terminal buffer %d (%s) is still running.'):format(bufnr, bufname(bufnr)),
                    { '&Ignore', '&Cancel' }
                )

                if choice ~= 'i' and choice ~= 'I' then
                    buf_is_deleted[bufnr] = nil
                end
            end
        end
    end

    if next(buf_is_deleted) == nil then
        vim.notify('debuf: No buffers were deleted', vim.log.levels.WARN)
        return
    end

    local windows = vim.iter(api.nvim_list_wins()):filter(function(win)
        return buf_is_deleted[api.nvim_win_get_buf(win)] ~= nil
    end):totable()

    if switchable_buffers ~= nil then
    elseif vim.g.debuf_buf_filter ~= nil then
        switchable_buffers = vim.g.debuf_buf_filter()
    else
        switchable_buffers = vim.iter(api.nvim_list_bufs()):filter(function(buf)
            return api.nvim_buf_is_valid(buf) and bo[buf].buflisted
        end):totable()
    end

    local undeleted_buffers = vim.iter(switchable_buffers):filter(function(buf)
        return not buf_is_deleted[buf]
    end):totable()

    local switch_bufnr
    if #undeleted_buffers > 0 then
        local switch_bufnr_lastused = -1

        for _, bufnr in ipairs(undeleted_buffers) do
            local bufinfo = fn.getbufinfo(bufnr)[1]
            if bufinfo.lastused > switch_bufnr_lastused then
                switch_bufnr = bufnr
                switch_bufnr_lastused = bufinfo.lastused
            end
        end
    else
        switch_bufnr = api.nvim_create_buf(true, false)

        if switch_bufnr == 0 then
            vim.notify('debuf: Failed to create buffer', vim.log.levels.ERROR)
            return
        end
    end

    for _, win in ipairs(windows) do
        api.nvim_win_set_buf(win, switch_bufnr)
    end

    for bufnr in pairs(buf_is_deleted) do
        if api.nvim_buf_is_loaded(bufnr) then
            local use_force = force or bo[bufnr].modified or bo[bufnr].buftype == 'terminal'

            api.nvim_exec_autocmds('User', { pattern = 'BDeletePre ' .. tostring(bufnr) })

            if wipeout then
                cmd.bwipeout({ count = bufnr, bang = use_force })
            else
                cmd.bdelete({ count = bufnr, bang = use_force })
            end

            api.nvim_exec_autocmds('User', { pattern = 'BDeletePost ' .. tostring(bufnr) })
        end
    end
end

local function find_buffer_with_pattern(pat)
    return vim.iter(api.nvim_list_bufs()):find(function(bufnr)
        return api.nvim_buf_is_valid(bufnr) and api.nvim_buf_get_name(bufnr):match(pat)
    end)
end

local function get_buffer_handle(buffer_or_pat)
    local bufnr

    if buffer_or_pat == nil then
        bufnr = 0
    elseif type(buffer_or_pat) == 'number' then
        bufnr = buffer_or_pat
    elseif type(buffer_or_pat) == 'string' then
        local n = tonumber(buffer_or_pat)
        if n ~= nil and math.floor(n) == n then
            bufnr = math.floor(n)
        else
            bufnr = find_buffer_with_pattern(buffer_or_pat)
        end
    end

    if bufnr == 0 then
        bufnr = api.nvim_get_current_buf()
    end

    if bufnr ~= nil and api.nvim_buf_is_valid(bufnr) then
        return bufnr
    end
end

local function get_target_buffers_from_range(left, right)
    local target_buffers = {}
    for i = left, right do
        if api.nvim_buf_is_valid(i) then
            target_buffers[#target_buffers + 1] = i
        end
    end
    return target_buffers
end

local function get_target_buffers(buffers)
    if type(buffers) ~= 'table' then
        return { get_buffer_handle(buffers) }
    end

    return vim.iter(buffers):map(function(v)
        return get_buffer_handle(v)
    end):filter(function(bufnr)
        return bufnr ~= nil
    end):totable()
end

function M.delete(buffers, force, switchable_buffers)
    buf_kill(get_target_buffers(buffers), switchable_buffers, force, false)
end

function M.wipeout(buffers, force, switchable_buffers)
    buf_kill(get_target_buffers(buffers), switchable_buffers, force, true)
end

function M._cmd(opts, wipeout)
    local target_buffers = get_target_buffers(opts.fargs)

    if #opts.fargs == 0 or opts.range > 0 then
        local range_left = opts.range == 2 and opts.line1 or opts.line2
        local range_right = opts.line2

        local new_targets = get_target_buffers_from_range(range_left, range_right)

        for _, v in ipairs(new_targets) do
            target_buffers[#target_buffers + 1] = v
        end
    end

    buf_kill(target_buffers, nil, opts.bang, wipeout)
end

return M
