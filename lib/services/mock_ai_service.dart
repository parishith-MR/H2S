import 'dart:math';

/// Mock AI Caption Generator
/// Produces structured dummy descriptions per sport category.
/// Replace generateCaption() body with a real Vision API call when ready.
class MockAIService {
  MockAIService._();

  static final _random = Random();

  static const Map<String, List<String>> _captionPool = {
    'Football': [
      'Football player sprinting down the field with the ball',
      'Crowd cheering enthusiastically in the stadium',
      'Player celebrating a goal with teammates',
      'Goalkeeper diving to make a save',
      'Referee showing a yellow card to a player',
      'Corner kick being taken by a player in red jersey',
      'Two players competing for aerial ball',
      'Team huddle on the sideline during a timeout',
      'Player dribbling past multiple defenders',
      'Free kick being lined up outside the penalty box',
      'Ball hitting the back of the net for a goal',
      'Players forming a defensive wall for free kick',
      'Coach giving instructions from the sideline',
      'Players in a tense tackle on the midfield',
      'Penalty kick being taken by the striker',
    ],
    'Cricket': [
      'Batsman hitting a powerful six over the boundary',
      'Bowler in delivery stride bowling fast',
      'Fielder taking a stunning catch at slip',
      'Wicket-keeper appealing for a dismissal',
      'Umpire raising finger for out decision',
      'Batsmen running between the wickets',
      'Spinner bowling with full rotation of arm',
      'Crowd waving flags and banners in the stands',
      'Captain having a discussion with teammates',
      'Player celebrating a century with raised bat',
      'Ball swinging through the air towards the batsman',
      'Team gathering at drinks break on the pitch',
      'Stumps flying after a bowled dismissal',
      'Player diving to prevent the ball crossing the boundary',
      'Scoreboard showing team total and wickets',
    ],
    'Tennis': [
      'Player serving with a powerful overhead motion',
      'Tennis player executing a backhand return',
      'Ball just clipping the net in a close point',
      'Player celebrating with fist pump after winning point',
      'Crowd on their feet applauding a great rally',
      'Player sliding on clay court to reach the ball',
      'Tennis ball bouncing just inside the baseline',
      'Match officials reviewing a line call',
      'Player toweling off at the changeover',
      'Overhead smash being played at the net',
      'Doubles partners congratulating each other',
      'Player arguing with the chair umpire',
      'Long baseline rally between two players',
      'Net player volleying the ball into open court',
      'Player looking at their racket after a mistake',
    ],
    'Basketball': [
      'Player dunking the ball with authority',
      'Three-point shot going through the net',
      'Guard breaking through defensive pressure',
      'Player blocking a shot at the rim',
      'Team celebrating a buzzer-beater play',
      'Coach drawing up a play during timeout',
      'Fast break leading to an easy layup',
      'Players jumping for the opening tip-off',
      'Crowd erupting after a spectacular dunk',
      'Player dribbling through traffic in the paint',
      'Free throw being shot in a crucial moment',
      'Defensive player stealing the ball from opponent',
      'Players arguing a foul call with the referee',
      'Player hitting a mid-range jump shot',
      'Bench players celebrating a big play',
    ],
    'Baseball': [
      'Batter swinging at a fastball pitch',
      'Pitcher winding up for a curveball delivery',
      'Outfielder making a diving catch',
      'Runner sliding into home plate',
      'Umpire calling the batter out on strikes',
      'Home run ball sailing into the upper deck',
      'Infielder turning a double play',
      'Catcher blocking a ball in the dirt',
      'Manager disputing a call with the umpire',
      'Crowd doing the wave around the stadium',
      'Player rounding third base at full speed',
      'Pitcher celebrating after a strikeout',
      'First baseman catching a throw for an out',
      'Broken bat flying during a swing',
      'Team celebrating a victory on the field',
    ],
    'Hockey': [
      'Player taking a powerful slap shot on goal',
      'Goalie making a spectacular glove save',
      'Players battling for the puck in the corner',
      'Hockey player celebrating a goal by the boards',
      'Referee separating players during a confrontation',
      'Power play unit setting up in the offensive zone',
      'Defenseman blocking a shot at the blue line',
      'Player skating at full speed on a breakaway',
      'Hockey puck hitting the crossbar of the net',
      'Teams lined up for the opening face-off',
      'Player being checked into the boards hard',
      'Crowd cheering after a home team goal',
      'Coach looking intense behind the players bench',
      'Penalty shot being taken against the goalkeeper',
      'Overtime winner celebration on the ice',
    ],
    'Rugby': [
      'Player diving over the try line to score',
      'Scrum forming between the two packs',
      'Line-out lifting player to catch the ball',
      'Kick being taken from in front of the posts',
      'Tackle being made by two defenders',
      'Players running in support of the ball carrier',
      'Crowd cheering after a successful conversion',
      'Referee blowing the whistle for a penalty',
      'Quick ball recycled from the breakdown',
      'Winger racing down the touchline with ball',
      'Halftime team talk by the head coach',
      'Drop goal attempt from outside the 22',
      'Player being stretchered off the field',
      'Maul pushing forward towards the try line',
      'Players in team huddle before a big play',
    ],
    'Swimming': [
      'Swimmer launching off the starting block',
      'Athlete performing butterfly stroke in the pool',
      'Touch pad registering a world record time',
      'Swimmer turning at the wall in the backstroke',
      'Medal ceremony with athletes on the podium',
      'Crowd watching intently from the stands',
      'Freestyle swimmer sprinting in the final lap',
      'Official reviewing the electronic timing board',
      'Swimmer celebrating after winning the race',
      'Team relay athletes waiting for the baton',
      'Underwater camera showing the dolphins kick',
      'Swimmer adjusting goggles before the race',
      'Close finish between two athletes at the wall',
      'Coaches watching from the pool deck',
      'Starting horn sounding for the beginning of the race',
    ],
    'Athletics': [
      'Sprinter exploding out of the starting blocks',
      'Long jumper soaring through the air at the pit',
      'High jumper clearing the bar with the Fosbury flop',
      'Marathon runner pushing through the final kilometer',
      'Discus thrower winding up for release',
      'Pole vaulter clearing the bar at world class height',
      'Relay baton being passed between two runners',
      'Javelin thrown releasing at the perfect angle',
      'Shot putter in the final rotation before release',
      'Crowd watching the hammer throw from a distance',
      'Triple jumper landing in the sand after a big jump',
      'Steeplechase runner clearing the water jump',
      'Athletes lined up at the start of the 100m final',
      'Winner breaking the finish line tape',
      'Athletes completing a lap on the Olympic track',
    ],
    'Other': [
      'Athletes competing on stage at an indoor event',
      'Official presenting a trophy to the winner',
      'Training session with a group of athletes',
      'Sports commentary team discussing the action',
      'Athletes at a pre-match press conference',
      'Warm-up exercises being performed by the team',
      'Medical staff attending to an injured player',
      'Fans celebrating in the stands and waving banners',
      'Sports journalist conducting an interview',
      'Players forming two teams before the match begins',
    ],
  };

  /// Generate a caption for the given sport category at a specific second index.
  /// The index is used to add variety via deterministic selection.
  static String generateCaption(String category, int secondIndex) {
    final pool = _captionPool[category] ?? _captionPool['Other']!;
    // Combine category-specific with generic to avoid repetition
    final allCaptions = [
      ...pool,
      ...(_captionPool['Other'] ?? []),
    ];
    // Deterministic selection based on secondIndex so same video = same captions
    return allCaptions[secondIndex % allCaptions.length];
  }

  /// Generate a list of captions for a sequence of frames.
  static List<String> generateCaptionBatch({
    required String category,
    required int frameCount,
  }) {
    return List.generate(
      frameCount,
      (i) => generateCaption(category, i),
    );
  }

  /// Randomly vary a caption slightly (for simulating different video angles).
  static String generateVariantCaption(String category, int secondIndex) {
    final base = generateCaption(category, secondIndex);
    final prefixes = [
      'Close-up of ',
      'Wide shot showing ',
      'Aerial view of ',
      '',
      '',
      '',
    ];
    final prefix = prefixes[_random.nextInt(prefixes.length)];
    return '$prefix${base[0].toLowerCase()}${base.substring(1)}';
  }
}
