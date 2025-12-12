use std::collections::HashMap;
use std::fs;

fn main() {
    let input = fs::read_to_string("input").unwrap();

    let parts: Vec<&str> = input.split("\n\n").collect();

    let mut shapes = HashMap::new();

    let mut regions: Vec<Region> = Vec::new();

    for i in 0..parts.len() - 1 {
        let idx = parts[i]
            .lines()
            .next()
            .unwrap()
            .strip_suffix(":")
            .unwrap()
            .parse::<usize>()
            .unwrap();

        let shape = parse_shape(&parts[i].lines().skip(1).collect::<Vec<&str>>().join("\n"));

        shapes.insert(idx, shape);
    }

    assert!(shapes.len() == 6);

    let region_lines: Vec<&str> = parts[parts.len() - 1].lines().collect();
    for rl in region_lines {
        let region = parse_region(rl);
        regions.push(region);
    }

    let p1 = part1(&shapes, &regions);
    println!("Part 1: {}", p1);
}

fn part1(shapes: &HashMap<usize, Shape>, regions: &Vec<Region>) -> usize {
    let mut fits = 0;
    for region in regions {
        let area = region.lxw.0 * region.lxw.1;

        let maximum_shapes_area: usize = region
            .num_shapes
            .iter()
            .enumerate()
            .map(|(idx, &num)| num * shapes.get(&idx).unwrap().points.len())
            .sum();

        if area >= maximum_shapes_area {
            fits += 1;
        }
    }

    fits
}

struct Shape {
    points: Vec<(usize, usize)>,
}

struct Region {
    lxw: (usize, usize),
    num_shapes: [usize; 6],
}

fn parse_region(data: &str) -> Region {
    let (lxw_str, nums_str) = data.split_once(":").unwrap();

    let lxw = lxw_str
        .split_once("x")
        .map(|(l, w)| (l.parse::<usize>().unwrap(), w.parse::<usize>().unwrap()))
        .unwrap();

    let nums: Vec<usize> = nums_str
        .split(" ")
        .skip(1)
        .map(|s| s.trim().parse::<usize>().unwrap())
        .collect();

    assert!(nums.len() == 6);

    let num_shapes = nums.try_into().unwrap();

    Region { lxw, num_shapes }
}

fn parse_shape(data: &str) -> Shape {
    let lines: Vec<&str> = data.lines().collect();

    let mut points = Vec::new();

    (0..lines.len()).for_each(|i| {
        for j in 0..lines[i].len() {
            if &lines[i][j..j + 1] == "#" {
                points.push((i, j));
            }
        }
    });

    Shape { points }
}
