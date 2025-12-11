use good_lp::{Expression, Solution, SolverModel, constraint, default_solver, variable, variables};
use std::collections::hash_map::Entry;
use std::collections::{HashMap, VecDeque};

fn main() {
    let lines = l25::file_lines("input").unwrap();

    let mut machines = Vec::with_capacity(lines.len());
    for line in lines {
        let machine = parse_machine(&line);
        machines.push(machine);
    }

    let p1 = part1(&machines);
    println!("part 1: {}", p1);
    let p2 = part2(&machines);
    println!("part 2: {}", p2);
}

fn part1(machines: &[Machine]) -> u32 {
    let mut total = 0;
    for machine in machines {
        total += min_presses_indicators(machine).unwrap_or(0);
    }
    total
}

fn min_presses_indicators(machine: &Machine) -> Option<u32> {
    let target = machine.indicators;
    if target == 0 {
        return Some(0);
    }

    let mut visited: HashMap<u32, u32> = HashMap::new();
    let mut states: VecDeque<(u32, u32)> = VecDeque::new();

    visited.insert(0, 0);
    states.push_back((0, 0));

    while let Some((state, presses)) = states.pop_front() {
        for &button in &machine.buttons_indicators {
            let new_state = state ^ button;
            if new_state == target {
                return Some(presses + 1);
            }
            if let Entry::Vacant(e) = visited.entry(new_state) {
                e.insert(presses + 1);
                states.push_back((new_state, presses + 1));
            }
        }
    }
    None
}

fn part2(machines: &[Machine]) -> u64 {
    let mut total = 0u64;
    for machine in machines {
        total += min_presses_joltages_ilp(machine);
    }
    total
}

fn min_presses_joltages_ilp(machine: &Machine) -> u64 {
    let target = &machine.joltages;
    let num_counters = target.len();
    let num_buttons = machine.buttons_joltages.len();

    if target.iter().all(|&x| x == 0) {
        return 0;
    }

    // Create variables
    let mut vars = variables!();

    // One integer variable per button
    let button_vars: Vec<_> = (0..num_buttons)
        .map(|_| vars.add(variable().integer().min(0)))
        .collect();

    //  minimize sum of all button presses
    let objective: Expression = button_vars.iter().sum();

    // Build the problem
    let mut problem = vars.minimise(objective).using(default_solver);

    // Add constraints
    for counter_idx in 0..num_counters {
        let mut sum: Expression = 0.into();

        for (btn_idx, btn) in machine.buttons_joltages.iter().enumerate() {
            if btn.contains(&(counter_idx as u32)) {
                sum += button_vars[btn_idx];
            }
        }

        problem = problem.with(constraint!(sum == target[counter_idx] as i32));
    }

    // Solve
    match problem.solve() {
        Ok(solution) => {
            let total: f64 = button_vars.iter().map(|&v| solution.value(v)).sum();
            total.round() as u64
        }
        Err(e) => {
            println!("No solution found: {:?}", e);
            u64::MAX
        }
    }
}

#[derive(Debug)]
struct Machine {
    indicators: u32,
    buttons_indicators: Vec<u32>,
    buttons_joltages: Vec<Vec<u32>>,
    joltages: Vec<u32>,
}

fn parse_machine(input: &str) -> Machine {
    let mut indicators = 0;
    let light_start = input.find('[').unwrap();
    let light_end = input.find(']').unwrap();
    let light_str = &input[light_start + 1..light_end];
    for (i, char) in light_str.chars().enumerate() {
        if char == '#' {
            indicators |= 1 << i;
        }
    }

    let mut buttons_indicators = Vec::new();
    let mut buttons_joltages = Vec::new();
    let mut i = light_end + 1;
    let chars: Vec<char> = input.chars().collect();

    let mut joltage_button = Vec::new();
    while i < chars.len() {
        if chars[i] == '(' {
            let mut j = i + 1;
            while j < chars.len() && chars[j] != ')' {
                j += 1;
            }
            let button_str: String = chars[i + 1..j].iter().collect();
            let mut mask = 0;
            for num_str in button_str.split(',') {
                let num = num_str.trim().parse::<u32>().unwrap();
                joltage_button.push(num);
                mask |= 1 << num;
            }
            buttons_indicators.push(mask);
            buttons_joltages.push(joltage_button.clone());
            joltage_button.clear();
            i = j + 1;
        } else if chars[i] == '{' {
            break;
        }
        i += 1;
    }

    let start = input.find('{').unwrap();
    let end = input.find('}').unwrap();

    let joltages = input[start + 1..end]
        .split(',')
        .map(|s| s.trim().parse::<u32>().unwrap())
        .collect();

    Machine {
        indicators,
        buttons_indicators,
        buttons_joltages,
        joltages,
    }
}
