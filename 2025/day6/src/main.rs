fn main() {
    let grid1 = l25::file_words_grid("input").unwrap();
    let columns: Vec<Vec<String>> = (0..grid1[0].len())
        .map(|col| grid1.iter().map(|row| row[col].clone()).collect())
        .collect();

    let p1 = part1(&columns);

    let mut grid2 = l25::file_to_grid("input").unwrap();
    let p2 = part2(&mut grid2);
    println!("Part 1: {}", p1);
    println!("Part 2: {}", p2);
}

fn part1(columns: &Vec<Vec<String>>) -> i64 {
    let mut total = 0;
    for column in columns {
        let values = (0..column.len() - 1)
            .map(|i| column[i].parse::<i64>().unwrap())
            .collect::<Vec<i64>>();
        if column[column.len() - 1] == "+" {
            total += values.iter().sum::<i64>();
        } else {
            total += values.iter().product::<i64>();
        }
    }
    total
}

fn part2(grid: &mut Vec<Vec<char>>) -> i64 {
    let mut total = 0;
    let mut op = '\0';
    let mut column_value = String::new();
    let mut col_val_int: i64;
    let mut problem_val = 0;

    let rows = grid.len();
    // cols needs to be the length of the longest row
    let cols = grid.iter().map(|r| r.len()).max().unwrap();

    // pad rows with spaces to make all rows the same length
    (0..rows).for_each(|r| {
        while grid[r].len() < cols {
            grid[r].push(' ');
        }
    });

    for i in 0..=cols {
        // if every row in the column is empty reset op and continue
        if i == cols || (0..rows).all(|j| grid[j][i] == ' ') {
            // println!("problem_val: {}", problem_val);
            total += problem_val;
            problem_val = 0;
            op = '\0';
            continue;
        }

        if op == '\0' {
            // get the operator
            op = grid[rows - 1][i];
            match op {
                '+' => problem_val = 0,
                '*' => problem_val = 1,
                _ => (),
            }
        }

        for j in 0..rows - 1 {
            if grid[j][i] != ' ' {
                column_value.push(grid[j][i]);
            }
        }

        // println!("op: {}", op);
        col_val_int = column_value.parse::<i64>().unwrap();
        match op {
            '+' => {
                problem_val += col_val_int;
            }
            '*' => {
                problem_val *= col_val_int;
            }
            _ => (),
        };
        column_value.clear();
    }

    total
}
