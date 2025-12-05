use std::fs::File;
use std::io::{BufRead, BufReader};

pub fn file_lines(path: &str) -> Result<Vec<String>, std::io::Error> {
    let file = File::open(path)?;
    let reader = BufReader::new(file);
    let lines = reader.lines().collect::<Result<Vec<_>, _>>()?;
    Ok(lines)
}

pub fn file_chars(path: &str) -> Result<Vec<char>, std::io::Error> {
    let content = std::fs::read_to_string(path)?;
    Ok(content.chars().collect())
}

pub fn file_to_grid(path: &str) -> Result<Vec<Vec<char>>, std::io::Error> {
    let lines = file_lines(path)?;
    let grid = lines
        .into_iter()
        .map(|line| line.chars().collect())
        .collect();
    Ok(grid)
}

pub fn grid_surrounding(grid: &Vec<Vec<char>>, row: usize, col: usize) -> Vec<char> {
    let mut surrounding = Vec::new();
    let rows = grid.len() as isize;
    let cols = grid[0].len() as isize;

    for dr in -1..=1 {
        for dc in -1..=1 {
            if dr == 0 && dc == 0 {
                continue;
            }
            let new_row = row as isize + dr;
            let new_col = col as isize + dc;
            if new_row >= 0 && new_row < rows && new_col >= 0 && new_col < cols {
                surrounding.push(grid[new_row as usize][new_col as usize]);
            }
        }
    }

    surrounding
}

pub fn parse_range(range_str: &str) -> Option<(i64, i64)> {
    let parts: Vec<&str> = range_str.split('-').collect();
    if parts.len() != 2 {
        return None;
    }
    let start = parts[0].parse::<i64>().ok()?;
    let end = parts[1].parse::<i64>().ok()?;
    Some((start, end))
}
