static ROCK: i32 = 1;
static PAPER: i32 = 2;
static SCISSOR: i32 = 3;

static LOSE: i32 = 0;
static DRAW: i32 = 3;
static WIN: i32 = 6;

fn main() {
    let lines = l22::file_lines("input").expect("could not read input");

    let mut score1 = 0;
    let mut score2 = 0;

    for line in lines {
        score1 += game_score(&line);
        score2 += game_score2(&line);
    }

    println!("total score (1): {score1}");
    println!("total score (2): {score2}");
}

fn game_score(game: &str) -> i32 {
    let opp = game.chars().next().expect("no game found");

    let me = game.chars().nth(2).expect("bad game");

    match me {
        'X' => match opp {
            'A' => ROCK + DRAW,
            'B' => ROCK + LOSE,
            'C' => ROCK + WIN,
            _ => panic!("invalid game"),
        },
        'Y' => match opp {
            'A' => PAPER + WIN,
            'B' => PAPER + DRAW,
            'C' => PAPER + LOSE,
            _ => panic!("invalid game"),
        },
        'Z' => match opp {
            'A' => SCISSOR + LOSE,
            'B' => SCISSOR + WIN,
            'C' => SCISSOR + DRAW,
            _ => panic!("invalid game"),
        },

        _ => panic!("invalid game"),
    }
}

fn game_score2(game: &str) -> i32 {
    let opp = game.chars().next().expect("no game found");

    let me = game.chars().nth(2).expect("bad game");

    match me {
        'X' => match opp {
            'A' => LOSE + SCISSOR,
            'B' => LOSE + ROCK,
            'C' => LOSE + PAPER,
            _ => panic!("invalid game"),
        },
        'Y' => match opp {
            'A' => DRAW + ROCK,
            'B' => DRAW + PAPER,
            'C' => DRAW + SCISSOR,
            _ => panic!("invalid game"),
        },
        'Z' => match opp {
            'A' => WIN + PAPER,
            'B' => WIN + SCISSOR,
            'C' => WIN + ROCK,
            _ => panic!("invalid game"),
        },

        _ => panic!("invalid game"),
    }
}
