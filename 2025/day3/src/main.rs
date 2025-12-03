fn main() {
    let banks = l25::file_lines("input").unwrap();

    let mut part1 = 0;
    let mut part2 = 0;

    for bank in banks {
        part1 += joltage_p1(&bank);
        part2 += joltage_p2(&bank);
    }

    println!("total joltage p1: {}", part1);
    println!("togal joltage p2: {}", part2);
}

fn joltage_p1(bank: &String) -> i32 {
    let mut max = 0;

    for a in 0..bank.len() {
        let d1 = &bank[a..a + 1];
        for b in a + 1..bank.len() {
            let d2 = &bank[b..b + 1];
            let val: i32 = (d1.to_owned() + d2).parse().unwrap();
            if val > max {
                max = val;
            }
        }
    }
    max
}

fn joltage_p2(bank: &String) -> u64 {
    let mut max = String::new();

    for i in 0..bank.len() {
        let d = &bank[i..i + 1];
        while max.len() > 0 && max[max.len() - 1..max.len()] < *d && bank.len() - i + max.len() > 12
        {
            max.pop();
        }

        if max.len() < 12 {
            max.push_str(d);
        }
    }
    max.parse().unwrap()
}
