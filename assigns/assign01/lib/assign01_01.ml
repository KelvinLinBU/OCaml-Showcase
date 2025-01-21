
let rec pow (n: int ) (k: int) : int = if k = 0 then 1 else n * pow n (k - 1);; (*If exponent is 0, then it's one. Base case. If not, then we make the recursive call*)