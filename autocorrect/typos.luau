-- Python 3 Spelling Corrector
--
-- Copyright 2014 Jonas McCallum.
-- Updated for Python 3, based on Peter Norvig's
-- 2007 version: http://norvig.com/spell-correct.html
--[[
Word based methods and functions

Author: Jonas McCallum
https://github.com/foobarmus/autocorrect

Optimized by: Filip Sondej
https://github.com/fifimajster/autocorrect/

Luau port by: Efe Bıkmaz
]]

--from itertools import chain
--from autocorrect.constants import alphabets

local constants = require("../autocorrect/constants")
local alphabets = constants.alphabets

local chain = require("../autocorrect/chain")
local str_table = require("../autocorrect/str_table")

--- container for word-based methods"""
--- @class Word
local Word = {}

--- @within Word
--- @interface Word
--- .slices { {string} }
--- .word string
--- .lang string
--- .alphabet string
--- .only_replacement boolean
export type Word = {
	typos: (self: Word) -> { string },
	double_typos: (self: Word) -> { string },

	_deletes: (self: Word) -> SliceGenerator,
	_transposes: (self: Word) -> SliceGenerator,
	_replaces: (self: Word) -> SliceGenerator,
	_inserts: (self: Word) -> SliceGenerator,

	slices: { { string } },
	word: string,
	lang: string,
	alphabet: string,
	only_replacements: boolean,
}

--- @within Word
--- @type SliceGenerator () -> Word
export type SliceGenerator = () -> Word

--[=[
    Generate slices to assist with typo
    definitions.

    'the' => (('', 'the'), ('t', 'he'),
    ('th', 'e'), ('the', ''))
    @within Word
    @param word string
    @param lang string
    @param only_replacements boolean
    @return Word
--]=]
function Word.new(word: string, lang: string, only_replacements: boolean): Word
	local self = {
		typos = Word.typos,
		double_typos = Word.double_typos,

		_deletes = Word._deletes,
		_transposes = Word._transposes,
		_replaces = Word._replaces,
		_inserts = Word._inserts,
	}

	local slice_range = NumberRange.new(1, #word + 1)

	do
		local t = {}
		for i = slice_range.Min, slice_range.Max do
			table.insert(t, { string.sub(word, 1, i), string.sub(word, i, #word) })
		end

		self.slices = t
	end

	self.word = word
	self.lang = lang
	self.alphabet = alphabets[lang]
	self.only_replacements = only_replacements

	return self
end

--- th
--- @within Word
--- @method _deletes
--- @return SliceGenerator
--- @private
function Word._deletes(self: Word): SliceGenerator
	return function()
		local t = {}
		local length = #self.slices

		for i, v in self.slices do
			if i == length then
				break
			end

			local a = v[1]
			local b = v[2]
			table.insert(t, `{a}{string.sub(b, 2)}`)
		end

		return t
	end
end

--- teh
--- @within Word
--- @method _transposes
--- @return SliceGenerator
--- @private
function Word._transposes(self: Word): SliceGenerator
	return function()
		local t = {}
		local length = #self.slices

		for i, v in self.slices do
			if i == length or i == length - 1 then
				break
			end

			local a = v[1]
			local b = v[2]
			--yield "".join((a, b[1], b[0], b[2:]))
			table.insert(t, `{a}{b:sub(2, 2)}{b:sub(1, 1)}{b:sub(2)}`)
		end

		return t
	end
end

--- tge
--- @within Word
--- @method _replaces
--- @return SliceGenerator
--- @private
function Word._replaces(self: Word): SliceGenerator
	return function()
		local t = {}
		local length = #self.slices

		for i, v in self.slices do
			if i == length then
				break
			end
			local a = v[1]
			local b = v[2]

			for _, c in str_table(self.alphabet) do
				table.insert(t, `{a}{c}{b:sub(2)}`)
			end
		end

		return t
	end
end

--- thwe
--- @within Word
--- @method _inserts
--- @return SliceGenerator
--- @private
function Word._inserts(self: Word): SliceGenerator
	return function()
		local t = {}

		for i, v in self.slices do
			local a = v[1]
			local b = v[2]

			for _, c in str_table(self.alphabet) do
				table.insert(t, `{a}{c}{b}`)
			end
		end

		return t
	end
end

--- letter combinations one typo away from word
--- @within Word
--- @method typos
--- @return {string}
function Word.typos(self: Word): { string }
	if self.only_replacements then
		return chain(self:_replaces())
	else
		return chain(self:_deletes(), self:_transposes(), self:_replaces(), self:_inserts())
	end
end

--- letter combinations two typos away from word
--- @within Word
--- @method double_typos
--- @return {string}
function Word.double_typos(self: Word): { string }
	local list = {}
	for _, e1 in self:typos() do
		table.insert(list, Word.new(e1, self.lang, self.only_replacements):typos())
	end

	return chain(table.unpack(list))
end

return {
	Word = Word,
}
