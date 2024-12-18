require 'prime'

  num = 1
  while true
    factors1 = Prime.prime_division(num).count
    factors2 = Prime.prime_division(num + 1).count
    factors3 = Prime.prime_division(num + 2).count
    factors4 = Prime.prime_division(num + 3).count
    if factors1 == 4 && factors2 == 4 && factors3 == 4 && factors4 == 4
      p num
      break
    end
    num += 1
  end