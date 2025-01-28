local function r(str: string): string
	return string.format("%q", str)
end

local word_regexes = {
	["en"] = r("[A-Za-z]+"),
	["pl"] = r("[A-Za-zęĘóÓąĄśŚłŁżŻźŹćĆńŃ]+"),
	["ru"] = r(
		"[АаБбВвГгДдЕеЁёЖжЗзИиЙйКкЛлМмНнОоПпРрСсТтУуФфХхЦцЧчШшЩщЪъЫыЬьЭэЮюЯя]+"
	),
	["uk"] = r(
		"[АаБбВвГгҐґДдЕеЄєЖжЗзИиІіЇїЙйКкЛлМмНнОоПпРрСсТтУуФфХхЦцЧчШшЩщЬЮюЯя]+"
	),
	["tr"] = r("[a-zA-ZçÇğĞüÜöÖşŞıİ]+"),
	["es"] = r("[A-Za-zÁáÉéÍíÓóÚúÜüÑñ]+"),
	["pt"] = r("[a-zA-ZãáàâçéêíõóôúüÃÁÀÂÇÉÊÍÕÓÔÚÜ]+"),
	["cs"] = r(
		"[AÁBCČDĎEÉĚFGH(Ch)IÍJKLMNŇOÓPQRŘSŠTŤUÚŮVWXYÝZŽaábcčdďeéěfgh(ch)iíjklmnňoópqrřsštťuúůvwxyýzž]+"
	),
	["el"] = r("[α-ωΑ-ΩίϊΐόάέύϋΰήώΊΪΪ́ΌΆΈΎΫΫ́ΉΏ]+"),
	["it"] = r("[a-zA-ZãáàâçéêíõóôúüÃÁÀÂÇÉÊÍÕÓÔÚÜ]+"),
	["fr"] = r("[a-zA-ZãáàâçéêíõóôúüÃÁÀÂÇÉÊÍÕÓÔÚÜ]+"),
	["vi"] = r(
		"[a-zA-ZàáạảãÀÁẠẢÃằắặẳẵẰẮẶẲẴầấậẩẫẦẤẬẨẪèéẹẻẽÈÉẸẺẼềếệểễỀẾỆỂỄìíịỉĩÌÍỊỈĨòóọỏõÒÓỌỎÕồốộổỗỒỐỘỔỖờớợởỡỜỚỢỞỠùúụủũÙÚỤỦŨừứựửữỪỨỰỬỮỳýỵỷỹỲÝỴỶỸ]+"
	),

	["_keys"] = function(word_regexes: any): { string }
		local t = {}

		for key in word_regexes do
			if string.sub(key, 1, 1) ~= "_" then
				table.insert(t, key)
			end
		end

		return t
	end,
}

local alphabets = {
	["en"] = "abcdefghijklmnopqrstuvwxyz",
	["pl"] = "abcdefghijklmnopqrstuvwxyzęóąśłżźćń",
	["ru"] = "шиюынжсяплзухтвкйеобмцьёгдщэарчфъ",
	["uk"] = "фагксщроємшплуьцнжхїйювязтибґідеч",
	["tr"] = "abcçdefgğhıijklmnoöprsştuüvyzqwxÇĞİÜÖ",
	["es"] = "abcdefghijklmnopqrstuvwxyzáéíóúüñ",
	["pt"] = "abcdefghijklmnopqrstuvwxyzãáàâçéêíõóôúü",
	["cs"] = "aábcčdďeéěfgh(ch)iíjklmnňoópqrřsštťuúůvwxyýzž",
	["el"] = "αβγδεζηθικλμνξοπρςτυφχψωίϊΐόάέύϋΰήώ",
	["it"] = "abcdefghijklmnopqrstuvwxzyãáàâçéêíõóôúü",
	["fr"] = "abcdefghijklmnopqrstuvwxzyãáàâçéêíõóôúü",
	["vi"] = "aàảãáạăằẳẵắặâầẩẫấậbcdđeèẻẽéẹêềểễếệfghiìỉĩíịjklmnoòỏõóọôồổỗốộơờởỡớợpqrstuùủũúụưừửữứựvwxyỳỷỹýỵz",
}

return {
	word_regexes = word_regexes,
	alphabets = alphabets,
}
