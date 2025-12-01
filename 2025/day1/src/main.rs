fn main() {
    let lines = l25::file_lines("input").unwrap();

    let mut dial = 50;
    let mut zeroes = 0;
    let mut p2 = 0;

    for line in lines {
        let dir = if line.as_bytes()[0] == b'R' { 1 } else { -1 };

        let amt = &line[1..];
        let amt: i32 = amt.parse().unwrap();

        for _ in 0..amt {
            dial += dir;
            if dial % 100 == 0 {
                p2 += 1;
            }
        }

        if dial % 100 == 0 {
            zeroes += 1;
        }
    }

    println!("part1: {}", zeroes);
    println!("part2: {}", p2);
}
