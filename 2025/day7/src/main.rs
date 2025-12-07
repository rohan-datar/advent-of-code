fn main() {
    let grid = l25::file_to_grid("input").unwrap();
    // locate start
    let (s_x, s_y) = grid
        .iter()
        .enumerate()
        .find_map(|(y, row)| {
            row.iter()
                .enumerate()
                .find_map(|(x, &c)| if c == 'S' { Some((x, y)) } else { None })
        })
        .unwrap();

    let p1 = part1(&grid, (s_x, s_y));
    println!("Part 1: {}", p1);
    let p2 = part2(&grid, (s_x, s_y));
    println!("Part 2: {}", p2);
}

fn part1(grid: &[Vec<char>], start: (usize, usize)) -> usize {
    let mut beams = Vec::new();
    let mut h = start.1 + 1;
    let mut splits = 0;
    beams.push(start.0);

    while h < grid.len() {
        let mut new_beams = Vec::new();
        // println!("beams at height {}: {:?}", h, beams);
        for &beam in &beams {
            if grid[h][beam] != '^' {
                if !new_beams.contains(&beam) {
                    new_beams.push(beam);
                }
            } else {
                splits += 1;
                if !new_beams.contains(&(beam - 1)) && beam > 0 {
                    new_beams.push(beam - 1);
                }

                if !new_beams.contains(&(beam + 1)) && beam < grid[0].len() - 1 {
                    new_beams.push(beam + 1);
                }
            }
        }
        beams = new_beams;
        h += 1;
    }
    splits
}

fn part2(grid: &[Vec<char>], start: (usize, usize)) -> usize {
    use std::collections::HashMap;

    // Map from beam position to number of timelines at that position
    let mut beams: HashMap<usize, usize> = HashMap::new();
    let mut h = start.1 + 1;

    beams.insert(start.0, 1);

    while h < grid.len() {
        let mut new_beams: HashMap<usize, usize> = HashMap::new();
        for (&beam, &timelines) in &beams {
            if grid[h][beam] == '^' {
                // Each timeline splits into two
                if beam > 0 {
                    *new_beams.entry(beam - 1).or_insert(0) += timelines;
                }
                if beam < grid[0].len() - 1 {
                    *new_beams.entry(beam + 1).or_insert(0) += timelines;
                }
            } else {
                *new_beams.entry(beam).or_insert(0) += timelines;
            }
        }
        beams = new_beams;
        h += 1;
    }

    // Sum up all timelines at the end
    beams.values().sum()
}
