use rand::Rng;
use std::cmp::Ordering;
use std::io;

fn main() {
    let mut s = String::from("hello");

    {
        let r1 = &mut s;
        println!("r1: {r1}");
        r1.push_str(", world");
    } // r1 goes out of scope here, so we can make a new reference with no problems.

    let r2 = &mut s;
    println!("r2: {r2}");
}

fn game() {
    println!("Guess the number!");

    let secret_number = rand::thread_rng().gen_range(1..=100);

    println!("the secret number is: {secret_number}");

    loop {
        println!("Input your guess!");

        let mut guess = String::new();

        io::stdin()
            .read_line(&mut guess)
            .expect("failed to read line");

        let guess: u32 = match guess.trim().parse() {
            Ok(num) => num,
            Err(_) => {
                println!("Invalid: {guess}");
                continue;
            }
        };

        println!("You guessed: {guess}");

        match guess.cmp(&secret_number) {
            Ordering::Less => println!("too small!"),
            Ordering::Greater => println!("Too big!"),
            Ordering::Equal => {
                println!("You win!");
                break;
            }
        }
    }
}
