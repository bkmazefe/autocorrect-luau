--import json
--import re
--from collections import Counter, OrderedDict

--from autocorrect.constants import word_regexes
local constants = require("../autocorrect/constants")
local word_regexes = constants.word_regexes
local r = constants.r

local function get_words(filename: string, lang: string, encd: string)
	local word_regex = word_regexes[lang]
	local capitalized_regex = r("(.|^|<|\"|'|(|[|{)s*") + word_regexes[lang]
	--with open(filename, encoding=encd) as file:
	--for line in file:
	--line = re.sub(capitalized_regex, "", line)
	--yield from re.findall(word_regex, line)
end

local function count_words(src_filename, lang, encd, out_filename)
	if not encd then
		encd = "utf-8"
	end
	if not out_filename then
		out_filename = "word_count.json"
	end

	local words = get_words(src_filename, lang, encd)
	--local counts = Counter(words)
	--# make output file human readable
	--counts_list = list(counts.items())
	--counts_list.sort(key=lambda i: i[1], reverse=True)
	--counts_ord_dict = OrderedDict(counts_list)
	--with open(out_filename, "w") as outfile:
	--json.dump(counts_ord_dict, outfile, indent=4)
end

return {
	get_words = get_words,
	count_words = count_words,
}
