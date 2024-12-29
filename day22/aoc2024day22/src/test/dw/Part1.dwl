
%dw 2.0
output application/json
import * from dw::core::Arrays
import * from MySolution
import lines from dw::core::Strings

var sample1 = 123
var sampleSecrets = (1 to 10) map (i) -> predictSecret(sample1, i)
var sampleBuyers = lines(sampleInput) map (line) -> line as Number
// var samplePart1 = sum(log(sampleBuyers map (secret) -> predictSecret(secret, 2000)))
var realBuyers = lines(rawInput) map (line) -> line as Number
fun step1(n) = prune(n mix (64 * n))
fun step2(n) = prune(n mix (floor(n / 32)))
fun step3(n) = prune(n mix (2048 * n))
---
sum(log(realBuyers map (secret) -> predictSecret(secret, 2000)))
// sizeOf(realBuyers)
// predictSecret(123, 2000)
// 2049(65n + (65n/32))
// == 2049(65n(1/32)) with mod each step
// step1(10000)