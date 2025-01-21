

type 'a test = 
  
| TestCase of 'a
  | TestList of 'a test list

let rec fold_left op base test_suite = match test_suite with
  





| TestCase test_case -> op base test_case
  | TestList tests -> List.fold_left (fun acc test -> fold_left op acc test) base tests
