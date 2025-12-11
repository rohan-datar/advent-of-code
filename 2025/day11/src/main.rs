use std::collections::HashMap;

fn main() {
    let lines = l25::file_lines("input").unwrap();

    let devices = parse_devices(&lines);

    let p1 = part1(&devices);
    println!("Part 1: {}", p1);

    let p2 = part2(&devices);
    println!("Part 2: {}", p2);
}

fn parse_devices(lines: &[String]) -> HashMap<String, Vec<String>> {
    let mut devices: HashMap<String, Vec<String>> = HashMap::with_capacity(lines.len());
    for line in lines {
        let name = line.split(':').next().unwrap().to_string();
        let outputs: Vec<String> = line
            .split(':')
            .nth(1)
            .unwrap()
            .split(' ')
            .skip(1)
            .map(|s| s.trim().to_string())
            .collect();

        devices.insert(name, outputs);
    }

    devices
}

fn part1(devices: &HashMap<String, Vec<String>>) -> usize {
    let mut num_paths = 0;

    // use dfs from device you to out
    let mut visited: Vec<String> = Vec::new();

    dfs1(
        devices,
        &"out".to_string(),
        &"you".to_string(),
        &mut visited,
        &mut num_paths,
    );

    num_paths
}

fn dfs1(
    devices: &HashMap<String, Vec<String>>,
    target: &String,
    current: &String,
    visited: &mut Vec<String>,
    num_paths: &mut usize,
) {
    if current == target {
        *num_paths += 1;
        return;
    }

    visited.push(current.clone());

    let outputs = devices.get(current).unwrap();

    for output in outputs {
        if !visited.contains(output) {
            dfs1(devices, target, output, visited, num_paths);
        }
    }

    visited.pop();
}

fn part2(devices: &HashMap<String, Vec<String>>) -> usize {
    // use dfs from device you to out
    let mut cache: HashMap<(String, bool, bool), usize> = HashMap::new();

    dfs2(
        devices,
        &"out".to_string(),
        &"svr".to_string(),
        false,
        false,
        &mut cache,
    )
}

fn dfs2(
    devices: &HashMap<String, Vec<String>>,
    target: &String,
    current: &String,
    dac: bool,
    fft: bool,
    cache: &mut HashMap<(String, bool, bool), usize>,
) -> usize {
    let dac = dac || current == "dac";
    let fft = fft || current == "fft";
    if current == target {
        return if dac && fft { 1 } else { 0 };
    }

    let current_state = (current.clone(), dac, fft);
    if let Some(&count) = cache.get(&current_state) {
        return count;
    }

    let outputs = devices.get(current).unwrap();

    let total = outputs
        .iter()
        .map(|output| dfs2(devices, target, output, dac, fft, cache))
        .sum();

    cache.insert(current_state, total);
    total
}
