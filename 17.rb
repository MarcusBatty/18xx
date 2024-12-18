def num_to_letters(n)
  case n
  when 1 then 'one'
  when 2 then 'two'
  when 3 then 'three'
  when 4 then 'four'
  when 5 then 'five'
  when 6 then 'six'
  when 7 then 'seven'
  when 8 then 'eight'
  when 9 then 'nine'
  when 10 then 'ten'
  when 11 then 'eleven'
  when 12 then 'twelve'
  when 13 then 'thirteen'
  when 14 then 'fourteen'
  when 15 then 'fifteen'
  when 16 then 'sixteen'
  when 17 then 'seventeen'
  when 18 then 'eighteen'
  when 19 then 'nineteen'
  end
end

def num_to_letters_tens(n)
  case n
  when 2 then 'twenty'
  when 3 then 'thirty'
  when 4 then 'forty'
  when 5 then 'fifty'
  when 6 then 'sixty'
  when 7 then 'seventy'
  when 8 then 'eighty'
  when 9 then 'ninety'
  end
end

arr = []
1000.times do |num|
  temp_arr = []
  num = (num + 1).to_s
  if num.size > 2
    temp_arr << num_to_letters(num[0].to_i)
    temp_arr << 'hundred' if num.size == 3
    temp_arr << 'thousand' if num.size == 4
    temp_arr << 'and' if num[-2,2] != '00'
    num = num[-2,2]
  end
  if num.to_i < 20
    temp_arr << num_to_letters(num.to_i)
  else
  temp_arr << num_to_letters_tens(num[0].to_i) 
  temp_arr << num_to_letters(num[1].to_i) 
  end
arr << temp_arr.compact.join
end
p arr.join.size