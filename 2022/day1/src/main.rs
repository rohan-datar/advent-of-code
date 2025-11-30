fn main() {
    let lines = l22::file_lines("input").expect("unable to read input");

    let mut elfs: Vec<i32> = Vec::new();

    let mut elf: i32 = 0;
    for line in lines {
        if line.is_empty() {
            elfs.push(elf);
            elf = 0;
        } else {
            let cal: i32 = line.parse().expect("unable to parse line");
            elf += cal;
        }
    }

    elfs.sort_by(|a, b| b.cmp(a));

    println!("max calories: {}", elfs[0]);

    let top_three = elfs[0..3].iter().sum::<i32>();

    println!("top three calories: {}", top_three);
}
