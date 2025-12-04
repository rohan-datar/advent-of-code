fn main() {
    let mut grid = l25::file_to_grid("input").unwrap();

    let p1 = part1(&grid);

    let p2 = part2(&mut grid);

    println!("Part 1: {}", p1);
    println!("Part 2: {}", p2);
}

fn part2(grid: &mut Vec<Vec<char>>) -> usize {
    let mut p2 = 0;

    loop {
        let mut rolls_to_remove = Vec::new();
        (0..grid.len()).for_each(|i| {
            (0..grid[0].len()).for_each(|j| {
                if grid[i][j] == '@' {
                    let surrounding = l25::grid_surrounding(grid, i, j);
                    if surrounding.iter().filter(|&&c| c == '@').count() < 4 {
                        rolls_to_remove.push((i, j));
                        p2 += 1;
                    }
                }
            });
        });

        if rolls_to_remove.is_empty() {
            break;
        }

        for (i, j) in &rolls_to_remove {
            grid[*i][*j] = '.';
        }
    }
    p2
}

fn part1(grid: &Vec<Vec<char>>) -> usize {
    let mut p1 = 0;

    (0..grid.len()).for_each(|i| {
        (0..grid[0].len()).for_each(|j| {
            if grid[i][j] == '@' {
                let surrounding = l25::grid_surrounding(&grid, i, j);
                if surrounding.iter().filter(|&&c| c == '@').count() < 4 {
                    p1 += 1;
                }
            }
        });
    });

    p1
}
