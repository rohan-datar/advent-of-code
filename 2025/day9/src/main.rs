fn main() {
    let lines = l25::file_lines("input").unwrap();

    let mut coordinates = Vec::with_capacity(lines.len());

    for line in lines {
        coordinates.push(parse_coordinate(&line));
    }

    let p1 = part1(&coordinates);
    println!("part1: {}", p1);
    let p2 = part2(&coordinates);
    println!("part2: {}", p2);
}

fn parse_coordinate(s: &str) -> (isize, isize) {
    let parts: Vec<&str> = s.trim().split(',').collect();
    let x = parts[0].parse::<isize>().unwrap();
    let y = parts[1].parse::<isize>().unwrap();
    (x, y)
}

fn part1(coords: &[(isize, isize)]) -> isize {
    let mut max: isize = 0;
    for i in 0..coords.len() {
        for j in (i + 1)..coords.len() {
            // get the area of the rectangle formed by coords[i] and coords[j]
            let area =
                ((coords[i].0 - coords[j].0).abs() + 1) * ((coords[i].1 - coords[j].1).abs() + 1);

            if area > max {
                max = area;
            }
        }
    }
    max
}

fn part2(coords: &[(isize, isize)]) -> isize {
    let mut max = 0;
    for i in 0..coords.len() {
        for j in (i + 1)..coords.len() {
            let (x1, y1) = coords[i];
            let (x2, y2) = coords[j];
            // check if both other corners are inside the polygon
            if is_inside((x1, y2), coords)
                && is_inside((x2, y1), coords)
                && !uncontained(x1, y1, x2, y2, coords)
            {
                let area = ((x1 - x2).abs() + 1) * ((y1 - y2).abs() + 1);
                if area > max {
                    max = area;
                }
            }
        }
    }
    max
}

// check if any edge of our polygon cuts through our rectangle
fn uncontained(x1: isize, y1: isize, x2: isize, y2: isize, coords: &[(isize, isize)]) -> bool {
    let (xmin, xmax) = if x1 < x2 { (x1, x2) } else { (x2, x1) };
    let (ymin, ymax) = if y1 < y2 { (y1, y2) } else { (y2, y1) };

    for i in 0..coords.len() {
        let (ex1, ey1) = coords[i];
        let (ex2, ey2) = coords[(i + 1) % coords.len()];

        if ex1 == ex2 {
            // vertical edge
            if ex1 > xmin && ex1 < xmax {
                let (eymin, eymax) = if ey1 < ey2 { (ey1, ey2) } else { (ey2, ey1) };
                if eymin < ymax && eymax > ymin {
                    return true;
                }
            }
        } else if ey1 == ey2 {
            // horizontal edge
            if ey1 > ymin && ey1 < ymax {
                let (exmin, exmax) = if ex1 < ex2 { (ex1, ex2) } else { (ex2, ex1) };
                if exmin < xmax && exmax > xmin {
                    return true;
                }
            }
        }
    }
    false
}

// check if a point in inside our big polygon
fn is_inside(point: (isize, isize), coords: &[(isize, isize)]) -> bool {
    let (px, py) = point;

    let mut crossings = 0;
    for i in 0..coords.len() {
        let (x1, y1) = coords[i];
        let (x2, y2) = coords[(i + 1) % coords.len()];

        // check if on a boundary
        if x1 == x2 && px == x1 {
            let (ymin, ymax) = if y1 < y2 { (y1, y2) } else { (y2, y1) };
            if py >= ymin && py <= ymax {
                return true;
            }
        } else if y1 == y2 && py == y1 {
            let (xmin, xmax) = if x1 < x2 { (x1, x2) } else { (x2, x1) };
            if px >= xmin && px <= xmax {
                return true;
            }
        }

        // cast ray to the right
        if x1 == x2 && px < x1 {
            let (ymin, ymax) = if y1 < y2 { (y1, y2) } else { (y2, y1) };
            if py >= ymin && py < ymax {
                crossings += 1;
            }
        }
    }
    crossings % 2 == 1
}
