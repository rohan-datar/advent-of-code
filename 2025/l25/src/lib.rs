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

