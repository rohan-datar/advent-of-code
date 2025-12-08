static NUM_PAIRS: usize = 1000;

fn main() {
    let lines = l25::file_lines("input").unwrap();
    let mut boxes = Vec::new();

    for line in lines {
        boxes.push(parse_coordinate(&line));
    }

    let connections = find_connections(&boxes);
    let p1 = part1(&connections);
    println!("Part 1: {}", p1);
    let p2 = part2(&boxes, &connections);
    assert!(p2 != 0);
    println!("Part 2: {}", p2);
}

fn parse_coordinate(s: &str) -> (usize, usize, usize) {
    let parts: Vec<&str> = s.trim().split(',').collect();
    let x = parts[0].parse::<usize>().unwrap();
    let y = parts[1].parse::<usize>().unwrap();
    let z = parts[2].parse::<usize>().unwrap();
    (x, y, z)
}

#[derive(Debug)]
struct Conn {
    start: (usize, usize, usize),
    end: (usize, usize, usize),
    distance: usize,
}

fn find_connections(boxes: &[(usize, usize, usize)]) -> Vec<Conn> {
    let mut connections = Vec::with_capacity(boxes.len() * (boxes.len() - 1) / 2);

    for i in 0..boxes.len() {
        for j in (i + 1)..boxes.len() {
            // find the euclidean distance between boxes[i] and boxes[j]
            let distance = (boxes[i].0 as isize - boxes[j].0 as isize).pow(2)
                + (boxes[i].1 as isize - boxes[j].1 as isize).pow(2)
                + (boxes[i].2 as isize - boxes[j].2 as isize).pow(2);

            connections.push(Conn {
                start: boxes[i],
                end: boxes[j],
                distance: distance as usize,
            });
        }
    }

    connections.sort_unstable_by(|a, b| a.distance.cmp(&b.distance));
    connections
}

fn part1(connections: &[Conn]) -> usize {
    let mut circuits: Vec<Vec<(usize, usize, usize)>> = Vec::new();

    assert!(connections.len() >= NUM_PAIRS);

    (0..NUM_PAIRS).for_each(|i| {
        let start = connections[i].start;
        let end = connections[i].end;

        let start_circuit_idx = circuits.iter().position(|c| c.contains(&start));
        let end_circuit_idx = circuits.iter().position(|c| c.contains(&end));

        match (start_circuit_idx, end_circuit_idx) {
            (Some(s), Some(e)) if s == e => {}

            (Some(s), Some(e)) => {
                // Remove the higher index first to avoid invalidating the lower index
                let (keep, remove) = if s < e { (s, e) } else { (e, s) };
                let removed_circuit = circuits.remove(remove);
                circuits[keep].extend(removed_circuit);
            }

            (Some(s), None) => {
                circuits[s].push(end);
            }

            (None, Some(e)) => {
                circuits[e].push(start);
            }

            (None, None) => {
                circuits.push(vec![start, end]);
            }
        }
    });

    circuits.sort_unstable_by_key(|a| a.len());

    let top_three = circuits.iter().rev().take(3);

    top_three.map(|c| c.len()).product()
}

fn part2(boxes: &[(usize, usize, usize)], connections: &[Conn]) -> usize {
    let mut circuits: Vec<Vec<(usize, usize, usize)>> = Vec::with_capacity(boxes.len());
    for b in boxes {
        circuits.push(vec![*b]);
    }

    for i in 0..connections.len() {
        let start = connections[i].start;
        let end = connections[i].end;

        let start_circuit_idx = circuits.iter().position(|c| c.contains(&start));
        let end_circuit_idx = circuits.iter().position(|c| c.contains(&end));

        match (start_circuit_idx, end_circuit_idx) {
            (Some(s), Some(e)) if s == e => {}

            (Some(s), Some(e)) => {
                if circuits.len() == 2 {
                    return start.0 * end.0;
                }
                // Remove the higher index first to avoid invalidating the lower index
                let (keep, remove) = if s < e { (s, e) } else { (e, s) };
                let removed_circuit = circuits.remove(remove);
                circuits[keep].extend(removed_circuit);
            }

            (Some(s), None) => {
                if circuits.len() == 2 {
                    return start.0 * end.0;
                }
                circuits[s].push(end);
            }

            (None, Some(e)) => {
                if circuits.len() == 2 {
                    return start.0 * end.0;
                }
                circuits[e].push(start);
            }

            (None, None) => {
                circuits.push(vec![start, end]);
            }
        }
    }
    0
}
