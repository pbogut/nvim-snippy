local comb = require "snippy.parser.comb"
local lazy = comb.lazy
local many = comb.many
local map = comb.map
local one = comb.one
local opt = comb.opt
local pattern = comb.pattern
local seq = comb.seq
local skip = comb.skip
local token = comb.token

describe("Combinator tests", function ()
    it("Should parse text", function ()
        local text = skip('%.', '')
        local ok, result, pos = text('this is just text.', 1)
        assert.is_same(
            {ok, result, pos},
            {true, {'this is just text', 'this is just text'}, 18}
        )
    end)
    it("Should parse escaped text", function ()
        local text = skip('[{}]', '')
        local ok, result, pos = text('my \\$var = 1', 1)
        assert.is_same(
            {ok, result, pos},
            {true, {'my \\$var = 1', 'my $var = 1'}, 13}
        )
    end)
    it("Should parse single caracter", function ()
        local text = skip('[{}]', '')
        local ok, result, pos = text('x', 1)
        assert.is_same(
            {ok, result, pos},
            {true, {'x', 'x'}, 2}
        )
    end)
    it("Basic token", function ()
        local tok = token('foo')
        local ok, result, pos = tok('foo', 1)
        assert.is_same({ok, result, pos}, {true, 'foo', 4})
    end)
    it("Symbol token", function ()
        local tok = token('$')
        local ok, result, pos = tok('${1}', 1)
        assert.is_same({ok, result, pos}, {true, '$', 2})
    end)
    it("Invalid token", function ()
        local tok = token('$')
        local ok, result, pos = tok('foo', 1)
        assert.is_same({ok, result, pos}, {false, nil, 1})
    end)
    it("Map token", function ()
        local tok = map(token('$'), function (value)
            return {token = value}
        end)
        local ok, result, pos = tok('$', 1)
        assert.is_same({ok, result, pos}, {true, {token = '$'}, 2})
    end)
    it("Should parse a sequence of tokens and text", function ()
        local parser = map(seq(skip('%$', ''), token('$')), function (value)
            return {text = value[1][2], token = value[2]}
        end)
        local ok, result, pos = parser('foo $', 1)
        assert.is_same({ok, result, pos}, {true, {text = 'foo ', token = '$'}, 6})
    end)
    it("Should parse many of one", function ()
        local parser = many(one(token('$'), token('foo')))
        local ok, result, pos = parser('foo', 1)
        assert.is_same({ok, result, pos}, {true, {'foo'}, 4})
    end)
    it("Optional value should be ok", function ()
        local parser = opt(token('$'))
        local ok, result, pos = parser('', 1)
        assert.is_same({ok, result, pos}, {true, nil, 1})
    end)
    it("Should parse a lazy pattern", function ()
        local parser = lazy(function() return pattern("%d+") end)
        local ok, result, pos = parser('888', 1)
        assert.is_same({ok, result, pos}, {true, '888', 4})
    end)
end)
