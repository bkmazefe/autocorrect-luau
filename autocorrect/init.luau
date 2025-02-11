local constants = require("../autocorrect/constants")
local data = require("../autocorrect/data")
local word_regexes = constants.word_regexes

local typos = require("../autocorrect/typos")
local Word = typos.Word

local str_table = require("../autocorrect/str_table")
local chain = require("../autocorrect/chain")

local word_count_types = require("./data/word_count_types")

--- @within Speller
--- @param lang string
--- @return {[string]: number}
function load_from_module(lang: string)
	if not word_regexes[lang] then
		local supported_langs = table.concat(word_regexes:_keys(), ",")
		error(`language '{lang}' not supported supported languages: {supported_langs}`)
	end
	return data.getLang(lang)
end

--- @class Speller
local speller = {}

--- @within Speller
--- @interface Speller
--- .lang string
--- .threshold number
--- .nlp_data LanguageModel
--- .fast boolean
--- .only_replacements boolean
export type Speller = {
	existing: (self: Speller, words: { string }) -> { string },
	get_candidates: (self: Speller, word: string) -> { { number | string } },
	autocorrect_word: (self: Speller, word: string) -> string,
	autocorrect_sentence: (self: Speller, sentence: string) -> string,

	lang: string,
	threshold: number,
	nlp_data: word_count_types.LanguageModel,
	fast: boolean,
	only_replacements: boolean,
}

--[=[
	@within speller
	@param lang string?
	@param threshold number?
	@param nlp_data LanguageModel?
	@param fast boolean?
	@param only_replacements boolean?
	@return Speller
--]=]
function speller.new(
	lang: string?,
	threshold: number?,
	nlp_data: any?,
	fast: boolean?,
	only_replacements: boolean?
): Speller
	local self = {
		existing = speller.existing,
		get_candidates = speller.get_candidates,
		autocorrect_word = speller.autocorrect_word,
		autocorrect_sentence = speller.autocorrect_sentence,
	}

	self.lang = lang or "en"
	self.threshold = threshold or 0
	self.nlp_data = nlp_data or load_from_module(self.lang)
	self.fast = fast or false
	self.only_replacements = only_replacements or false

	if self.threshold > 0 then
		-- print(f'Original number of words: {len(self.nlp_data)}')
		local t = {}
		for k, v in self.nlp_data.items() do
			if v > self.threshold then
				t[k] = v
			end
		end
		self.nlp_data = t
		-- print(f'After applying threshold: {len(self.nlp_data)}')
	end

	return self
end

--- @within Speller
--- @method existing
--- @param words {string}
--- @return {string}
function speller.existing(self: Speller, words: { string }): { string }
	--"""{'the', 'teh'} => {'the'}"""
	--return {word for word in words if word in self.nlp_data}
	local t = {}
	for _, word in words do
		if self.nlp_data.get_count(word) then
			table.insert(word)
		end
	end

	return t
end

--- @within Speller
--- @method get_candidates
--- @param word string
--- @return { {number | string} }
function speller.get_candidates(self: Speller, word: string): { { number | string } }
	local w = Word.new(word, self.lang, self.only_replacements)
	local candidates

	if self.fast then
		candidates = self:existing({ word }) or self:existing(w.typos()) or { word }
	else
		candidates = (
			self:existing({ word })
			or self:existing(w.typos())
			or self:existing(w.double_typos())
			or { word }
		)
	end

	local t = {}
	for _, c in candidates do
		table.insert(t, { self.nlp_data.get_count(c), c })
	end

	return t
end

--- @within Speller
--- @method autocorrect_word
--- @param word string
--- @return string
function speller.autocorrect_word(self: Speller, word: string): string
	--"""most likely correction for everything up to a double typo"""
	if word == "" then
		return ""
	end

	local word_table = str_table(word)
	local candidates = self:get_candidates(word)

	--# in case the word is capitalized
	if word_table[1].upper() == word_table[1] then
		local decapitalized = word_table
		decapitalized[1] = word_table[1].lower()
		decapitalized = table.concat(word_table, "")

		candidates = chain(candidates, self:get_candidates(decapitalized))
	end

	local best_word = candidates[1]
	for _, candidate in candidates do
		if candidate[1] > best_word[1] then
			best_word = candidate
		end
	end

	if word_table[1].upper() == word_table[1] then
		best_word = str_table(best_word[2])
		best_word[1] = best_word[1].upper()
		best_word = table.concat(best_word, "")
	end

	return best_word
end

--- @within Speller
--- @method autocorrect_sentence
--- @param sentence string
--- @return string
function speller.autocorrect_sentence(self: Speller, sentence: string): string
	local word_pattern = word_regexes[self.lang] or "%w+"

	local function autocorrect(match)
		return self:autocorrect_word(match)
	end

	local corrected_sentence = sentence:gsub(word_pattern, autocorrect)

	return corrected_sentence
end

return function(sentence: string)
	local new_speller = speller.new("en")
	return new_speller:autocorrect_sentence(sentence)
end
