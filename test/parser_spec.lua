local inspect = vim and vim.inspect or require "inspect"

local parser = require  "snippy.parser"

describe("Parser tests", function ()
    it("Parse a basic snippet", function ()
        local snip = 'local $1 = ${2}'
        local ok, result, pos = parser.parse(snip, 1)
        assert.is_true(ok)
        assert.is_same(pos, #snip + 1)
        assert.is_same(result[#result],
            {type = 'tabstop', id = 2, children = {}})
    end)
    it("Parse a nested placeholder", function ()
        local snip = 'local ${1} = ${2:${3:bar}}'
        local ok, result, pos = parser.parse(snip, 1)
        assert.is_true(ok)
        assert.is_same(pos, #snip + 1)
        assert.is_same(result[#result],
            {type = 'placeholder', id = 2, children = {
                {type = 'placeholder', id = 3, children = {
                    {type = 'text', escaped = 'bar', raw = 'bar'}}}}})
    end)
    it("Parse a choice stop", function ()
        local snip = 'local ${1} = ${2|option1, option2, option3|}'
        local ok, result, pos = parser.parse(snip, 1)
        assert.is_true(ok)
        assert.is_same(pos, #snip + 1)
        assert.is_same(result[#result],
            {type = 'choice', id = 2, children = {[1] = 'option1'},
                choices = {'option1', 'option2', 'option3'}})
    end)
    it("Parse a transform tabstop", function ()
        local snip = 'local ${1} = ${2/foo/bar/ig}'
        local ok, result, pos = parser.parse(snip, 1)
        assert.is_true(ok)
        assert.is_same(pos, #snip + 1)
        assert.is_same(result[#result],
            {type = 'tabstop', id = 2, children = {}, transform = {
                type = 'transform',
                flags = 'ig',
                regex = {type = 'text', raw = 'foo', escaped = 'foo'},
                format = {type = 'text', raw = 'bar', escaped = 'bar'},
            }})
    end)
    it("Parse a transform without flags", function ()
        local snip = 'local ${1} = ${2/foo/bar}'
        local ok, result, pos = parser.parse(snip, 1)
        assert.is_true(ok)
        assert.is_same(pos, #snip + 1)
        assert.is_same(result[#result],
            {type = 'tabstop', id = 2, children = {}, transform = {
                type = 'transform',
                flags = '',
                regex = {type = 'text', raw = 'foo', escaped = 'foo'},
                format = {type = 'text', raw = 'bar', escaped = 'bar'},
            }})
    end)
    it("Parse variables", function ()
        local snip = 'local ${1} = ${TM_CURRENT_YEAR}'
        local ok, result, pos = parser.parse(snip, 1)
        assert.is_true(ok)
        assert.is_same(pos, #snip + 1)
        assert.is_same(result[#result],
            {type = 'variable', name = 'TM_CURRENT_YEAR', children = {}})
    end)
    it("Parse variables with children", function ()
        local snip = 'local ${1} = ${TM_CURRENT_YEAR:1992}'
        local ok, result, pos = parser.parse(snip, 1)
        assert.is_true(ok)
        assert.is_same(pos, #snip + 1)
        assert.is_same(result[#result],
            {type = 'variable', name = 'TM_CURRENT_YEAR', children =
                {[1] = {type = 'text', raw = '1992', escaped = '1992'}}})
    end)
    it("Parse single ending character", function ()
        local snip = 'local ${1} = "${2:snip}"'
        local ok, result, pos = parser.parse(snip, 1)
        assert.is_true(ok)
        assert.is_same(pos, #snip + 1)
        assert.is_same(result[#result],
            {type = 'text', raw = '"', escaped = '"'})
    end)
    it("Parse SnipMate eval", function ()
        local snip = 'local ${1} = `g:snips_author`'
        local ok, result, pos = parser.parse_snipmate(snip, 1)
        assert.is_true(ok)
        assert.is_same(pos, #snip + 1)
        assert.is_same(result[#result],
            {type = 'eval', children =
                {[1] = {type = 'text', raw = 'g:snips_author', escaped = 'g:snips_author'}}})
    end)
end)
