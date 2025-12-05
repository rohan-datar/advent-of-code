fn main() {
    let lines = l25::file_lines("input").unwrap();

    let mut ranges = Vec::new();
    let mut ingredients = Vec::new();

    let mut i = 0;
    loop {
        if lines[i].is_empty() {
            i += 1;
            break;
        }

        let range = l25::parse_range(&lines[i]).unwrap();
        ranges.push(range);
        i += 1;
    }

    (i..lines.len()).for_each(|j| {
        let ingredient: i64 = lines[j].parse().unwrap();
        ingredients.push(ingredient);
    });

    let p1 = part1(&ranges, &ingredients);
    let p2 = part2(&ranges);
    println!("Part 1: {}", p1);
    println!("Part 2: {}", p2);
}

fn part1(ranges: &Vec<(i64, i64)>, ingredients: &Vec<i64>) -> i64 {
    let mut total = 0;

    for &ingredient in ingredients {
        for (start, end) in ranges {
            if ingredient >= *start && ingredient <= *end {
                total += 1;
                break;
            }
        }
    }

    total
}

fn part2(ranges: &Vec<(i64, i64)>) -> i64 {
    let mut total = 0;
    let mut ranges = ranges.clone();
    ranges.sort_unstable_by_key(|(s, _e)| *s);

    let mut start = 0;
    let mut end = 0;

    for &(s, e) in &ranges {
        // if overlap with the previous range
        if s < end {
            // calculate the new end
            end = end.max(e + 1);
        } else {
            // otherwise, add the previous range size
            total += end - start;

            start = s;
            end = e + 1;
        }
    }

    total + end - start
}
