fn main() {
    let input = std::fs::read_to_string("input").unwrap();

    let id_list: Vec<&str> = input.split(",").collect();

    let mut part1 = 0;
    let mut part2 = 0;

    for id_range in id_list {
        let start = id_range.split("-").next().unwrap();
        let end = id_range.split("-").nth(1).unwrap().trim();

        let start = start.parse::<u64>().unwrap();
        let end = end.parse::<u64>().unwrap();

        for i in start..end + 1 {
            let digits = i.to_string();

            let half = digits.len() / 2;

            if digits[0..half] == digits[half..] {
                part1 += i;
            }

            for j in 1..digits.len() {
                if digits.len().is_multiple_of(j) {
                    let pattern = &digits[..j];
                    let mut is_invalid = true;

                    for k in (0..digits.len()).step_by(j) {
                        let end = if j + k > digits.len() {
                            digits.len()
                        } else {
                            j + k
                        };
                        if &digits[k..end] != pattern {
                            is_invalid = false;
                            break;
                        }
                    }

                    if is_invalid {
                        part2 += i;
                        break;
                    }
                }
            }
        }
    }

    println!("total invalid: {}", part1);
    println!("total invalid: {}", part2);
}
