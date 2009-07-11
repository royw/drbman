Thread ID: 108760
Total Time: 487.6284

  %total   %self     total      self      wait     child            calls   Name
--------------------------------------------------------------------------------
 100.00%   0.00%    487.63      0.00      0.00    487.63                1     <Class::SieveOfEratosthenes>#profile (./examples/primes/sieve_of_eratosthenes.rb:25}  ./examples/primes/sieve_of_eratosthenes.rb:25
                    487.63      0.00      0.00    487.63              1/1     Proc#call
--------------------------------------------------------------------------------
                    487.63      0.00      0.00    487.63              1/1     <Class::SieveOfEratosthenes>#profile
 100.00%   0.00%    487.63      0.00      0.00    487.63                1     Proc#call (ruby_runtime:0}  ruby_runtime:0
                    487.63      0.00      0.00    487.63              1/1     SieveOfEratosthenes#primes
--------------------------------------------------------------------------------
                    487.63      0.00      0.00    487.63              1/1     Proc#call
 100.00%   0.00%    487.63      0.00      0.00    487.63                1     SieveOfEratosthenes#primes (./examples/primes/sieve_of_eratosthenes.rb:41}  ./examples/primes/sieve_of_eratosthenes.rb:41
                    310.72      0.00      0.00    310.72              1/1     SieveOfEratosthenes#calc_composites
                     12.27     12.27      0.00      0.00              1/4     Array#uniq
                      0.00      0.00      0.00      0.00              1/5     Fixnum#>
                      0.00      0.00      0.00      0.00            2/476     <Class::Object>#allocate
                      9.21      9.21      0.00      0.00              1/4     Array#flatten
                    155.43      0.00      0.00    155.43              1/4     SieveOfEratosthenes#calc_indices
--------------------------------------------------------------------------------
                    310.60      0.01      0.00    310.59             2/12     SieveOfEratosthenes#calc_composites
                      0.07      0.00      0.00      0.07             6/12     SieveOfEratosthenes#calc_composites-1
                     64.36     43.51      0.00     20.86             4/12     SieveOfEratosthenes#calc_indices
  76.91%   8.92%    375.03     43.51      0.00    331.52               12     Array#each (ruby_runtime:0}  ruby_runtime:0
                      0.05      0.05      0.00      0.00     468/24162974     Array#<<
                      0.01      0.00      0.00      0.00          468/472     Class#new
                    310.60      0.33      0.00    310.27          468/468     PrimeHelper#non_primes
                     20.86     20.86      0.00      0.00  9338170/9338170     Array#[]=
--------------------------------------------------------------------------------
                    310.72      0.00      0.00    310.72              1/1     SieveOfEratosthenes#primes
  63.72%   0.00%    310.72      0.00      0.00    310.72                1     SieveOfEratosthenes#calc_composites (./examples/primes/sieve_of_eratosthenes.rb:52}  ./examples/primes/sieve_of_eratosthenes.rb:52
                      0.00      0.00      0.00      0.00              1/4     <Module::Math>#sqrt
                      0.00      0.00      0.00      0.00              1/4     Float#to_i
                    310.60      0.01      0.00    310.59             2/12     Array#each
                      0.13      0.00      0.00      0.13              1/4     SieveOfEratosthenes#primes-1
--------------------------------------------------------------------------------
                    310.60      0.33      0.00    310.27          468/468     Array#each
  63.70%   0.07%    310.60      0.33      0.00    310.27              468     PrimeHelper#non_primes (./examples/primes/sieve_of_eratosthenes.rb:7}  ./examples/primes/sieve_of_eratosthenes.rb:7
                      0.00      0.00      0.00      0.00          468/468     Fixnum#/
                      0.00      0.00      0.00      0.00          468/468     Fixnum#-
                    310.27    206.46      0.00    103.81          468/468     Integer#upto
--------------------------------------------------------------------------------
                    310.27    206.46      0.00    103.81          468/468     PrimeHelper#non_primes
  63.63%  42.34%    310.27    206.46      0.00    103.81              468     Integer#upto (ruby_runtime:0}  ruby_runtime:0
                     52.19     52.19      0.00      0.0023497451/24162974     Array#<<
                     51.63     51.63      0.00      0.0023497451/23497451     Fixnum#*
--------------------------------------------------------------------------------
                    155.43      0.00      0.00    155.43              1/4     SieveOfEratosthenes#primes
                      0.05      0.00      0.00      0.05              3/4     SieveOfEratosthenes#primes-1
  31.88%   0.00%    155.48      0.00      0.00    155.48                4     SieveOfEratosthenes#calc_indices (./examples/primes/sieve_of_eratosthenes.rb:70}  ./examples/primes/sieve_of_eratosthenes.rb:70
                      0.06      0.00      0.00      0.06            4/472     Class#new
                      0.00      0.00      0.00      0.00              4/4     Array#shift
                     64.36     43.51      0.00     20.86             4/12     Array#each
                     91.05     67.69      0.00     23.37              4/4     Array#each_index
--------------------------------------------------------------------------------
                     91.05     67.69      0.00     23.37              4/4     SieveOfEratosthenes#calc_indices
  18.67%  13.88%     91.05     67.69      0.00     23.37                4     Array#each_index (ruby_runtime:0}  ruby_runtime:0
                      1.50      1.50      0.00      0.00  665055/24162974     Array#<<
                     21.86     21.86      0.00      0.0010003225/10003225     Array#[]
--------------------------------------------------------------------------------
                      0.05      0.05      0.00      0.00     468/24162974     Array#each
                     52.19     52.19      0.00      0.0023497451/24162974     Integer#upto
                      1.50      1.50      0.00      0.00  665055/24162974     Array#each_index
  11.02%  11.02%     53.74     53.74      0.00      0.00         24162974     Array#<< (ruby_runtime:0}  ruby_runtime:0
--------------------------------------------------------------------------------
                     51.63     51.63      0.00      0.0023497451/23497451     Integer#upto
  10.59%  10.59%     51.63     51.63      0.00      0.00         23497451     Fixnum#* (ruby_runtime:0}  ruby_runtime:0
--------------------------------------------------------------------------------
                     21.86     21.86      0.00      0.0010003225/10003225     Array#each_index
   4.48%   4.48%     21.86     21.86      0.00      0.00         10003225     Array#[] (ruby_runtime:0}  ruby_runtime:0
--------------------------------------------------------------------------------
                     20.86     20.86      0.00      0.00  9338170/9338170     Array#each
   4.28%   4.28%     20.86     20.86      0.00      0.00          9338170     Array#[]= (ruby_runtime:0}  ruby_runtime:0
--------------------------------------------------------------------------------
                     12.27     12.27      0.00      0.00              1/4     SieveOfEratosthenes#primes
                      0.00      0.00      0.00      0.00              3/4     SieveOfEratosthenes#primes-1
   2.52%   2.52%     12.27     12.27      0.00      0.00                4     Array#uniq (ruby_runtime:0}  ruby_runtime:0
--------------------------------------------------------------------------------
                      9.21      9.21      0.00      0.00              1/4     SieveOfEratosthenes#primes
                      0.00      0.00      0.00      0.00              3/4     SieveOfEratosthenes#primes-1
   1.89%   1.89%      9.21      9.21      0.00      0.00                4     Array#flatten (ruby_runtime:0}  ruby_runtime:0
--------------------------------------------------------------------------------
                      0.13      0.00      0.00      0.13              1/4     SieveOfEratosthenes#calc_composites
                      0.00      0.00      0.00      0.00              3/4     SieveOfEratosthenes#calc_composites-1
   0.03%   0.00%      0.13      0.00      0.00      0.13                4     SieveOfEratosthenes#primes-1 (./examples/primes/sieve_of_eratosthenes.rb:41}  ./examples/primes/sieve_of_eratosthenes.rb:41
                      0.00      0.00      0.00      0.00              3/4     Array#uniq
                      0.00      0.00      0.00      0.00              4/5     Fixnum#>
                      0.08      0.00      0.00      0.08              3/3     SieveOfEratosthenes#calc_composites-1
                      0.00      0.00      0.00      0.00            6/476     <Class::Object>#allocate
                      0.00      0.00      0.00      0.00              3/4     Array#flatten
                      0.05      0.00      0.00      0.05              3/4     SieveOfEratosthenes#calc_indices
--------------------------------------------------------------------------------
                      0.08      0.00      0.00      0.08              3/3     SieveOfEratosthenes#primes-1
   0.02%   0.00%      0.08      0.00      0.00      0.08                3     SieveOfEratosthenes#calc_composites-1 (./examples/primes/sieve_of_eratosthenes.rb:52}  ./examples/primes/sieve_of_eratosthenes.rb:52
                      0.00      0.00      0.00      0.00              3/4     <Module::Math>#sqrt
                      0.00      0.00      0.00      0.00              3/4     Float#to_i
                      0.07      0.00      0.00      0.07             6/12     Array#each
                      0.00      0.00      0.00      0.00              3/4     SieveOfEratosthenes#primes-1
--------------------------------------------------------------------------------
                      0.01      0.00      0.00      0.00          468/472     Array#each
                      0.06      0.00      0.00      0.06            4/472     SieveOfEratosthenes#calc_indices
   0.01%   0.00%      0.07      0.00      0.00      0.06              472     Class#new (ruby_runtime:0}  ruby_runtime:0
                      0.00      0.00      0.00      0.00              4/4     <Class::Array>#allocate
                      0.00      0.00      0.00      0.00          468/476     <Class::Object>#allocate
                      0.00      0.00      0.00      0.00          468/468     Object#initialize
                      0.06      0.06      0.00      0.00              4/4     Array#initialize
--------------------------------------------------------------------------------
                      0.06      0.06      0.00      0.00              4/4     Class#new
   0.01%   0.01%      0.06      0.06      0.00      0.00                4     Array#initialize (ruby_runtime:0}  ruby_runtime:0
--------------------------------------------------------------------------------
                      0.00      0.00      0.00      0.00          468/468     PrimeHelper#non_primes
   0.00%   0.00%      0.00      0.00      0.00      0.00              468     Fixnum#- (ruby_runtime:0}  ruby_runtime:0
--------------------------------------------------------------------------------
                      0.00      0.00      0.00      0.00          468/476     Class#new
                      0.00      0.00      0.00      0.00            2/476     SieveOfEratosthenes#primes
                      0.00      0.00      0.00      0.00            6/476     SieveOfEratosthenes#primes-1
   0.00%   0.00%      0.00      0.00      0.00      0.00              476     <Class::Object>#allocate (ruby_runtime:0}  ruby_runtime:0
--------------------------------------------------------------------------------
                      0.00      0.00      0.00      0.00          468/468     PrimeHelper#non_primes
   0.00%   0.00%      0.00      0.00      0.00      0.00              468     Fixnum#/ (ruby_runtime:0}  ruby_runtime:0
--------------------------------------------------------------------------------
                      0.00      0.00      0.00      0.00          468/468     Class#new
   0.00%   0.00%      0.00      0.00      0.00      0.00              468     Object#initialize (ruby_runtime:0}  ruby_runtime:0
--------------------------------------------------------------------------------
                      0.00      0.00      0.00      0.00              4/4     SieveOfEratosthenes#calc_indices
   0.00%   0.00%      0.00      0.00      0.00      0.00                4     Array#shift (ruby_runtime:0}  ruby_runtime:0
--------------------------------------------------------------------------------
                      0.00      0.00      0.00      0.00              1/5     SieveOfEratosthenes#primes
                      0.00      0.00      0.00      0.00              4/5     SieveOfEratosthenes#primes-1
   0.00%   0.00%      0.00      0.00      0.00      0.00                5     Fixnum#> (ruby_runtime:0}  ruby_runtime:0
--------------------------------------------------------------------------------
                      0.00      0.00      0.00      0.00              1/4     SieveOfEratosthenes#calc_composites
                      0.00      0.00      0.00      0.00              3/4     SieveOfEratosthenes#calc_composites-1
   0.00%   0.00%      0.00      0.00      0.00      0.00                4     <Module::Math>#sqrt (ruby_runtime:0}  ruby_runtime:0
--------------------------------------------------------------------------------
                      0.00      0.00      0.00      0.00              4/4     Class#new
   0.00%   0.00%      0.00      0.00      0.00      0.00                4     <Class::Array>#allocate (ruby_runtime:0}  ruby_runtime:0
--------------------------------------------------------------------------------
                      0.00      0.00      0.00      0.00              1/4     SieveOfEratosthenes#calc_composites
                      0.00      0.00      0.00      0.00              3/4     SieveOfEratosthenes#calc_composites-1
   0.00%   0.00%      0.00      0.00      0.00      0.00                4     Float#to_i (ruby_runtime:0}  ruby_runtime:0


