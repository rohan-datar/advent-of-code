print("Hello World!")

let label = "The width is "
let width = 94
let widthLabel = label + String(width)


var optionalString: String? = "Hello"
print(optionalString == nil)
// Prints "false"


var optionalName: String? = "John Appleseed"
var greeting = "Hello!"
if let name = optionalName {
    greeting = "Hello, \(name)"
}

print(greeting)

let nickname: String? = nil
let fullName: String = "John Appleseed"
let informalGreeting = "Hi \(nickname ?? fullName)"
print(informalGreeting)

if let nickname {
    print("Hey, \(nickname)")
}

let vegetable = "red pepper"
switch vegetable {
case "celery":
    print("Add some raisins and make ants on a log.")
case "cucumber", "watercress":
    print("That would make a good tea sandwich.")
case let x where x.hasSuffix("pepper"):
    print("Is it a spicy \(x)?")
 default:
     print("Everything tastes good in soup.")
}
// Prints "Is it a spicy red pepper?"


let digits = ["0":"zero", "1":"one", "2":"two", "3":"three", "4": "four", "5": "five", "6": "six", "7": "seven", "8":"eight", "9": "nine"]

for (digit, word) in digits {
    print("digit: \(digit) \(word)")
}

let mod = 13 % 10
print(mod)
print((10 + mod) % 10)

print(5/2)
