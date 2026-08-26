import 'package:flutter_test/flutter_test.dart';
import 'package:righthere_rightnow/data/calendar/conference_link_extractor.dart';

void main() {
  test('extracts a Google Meet link', () {
    const description =
        'Join: https://meet.google.com/abc-defg-hij\n\nAgenda...';

    expect(
      extractConferenceUrl(description),
      'https://meet.google.com/abc-defg-hij',
    );
  });

  test('extracts a Zoom link', () {
    const description =
        'Join Zoom Meeting\nhttps://us02web.zoom.us/j/123456789';

    expect(
      extractConferenceUrl(description),
      'https://us02web.zoom.us/j/123456789',
    );
  });

  test('extracts a bare zoom.us link with no subdomain', () {
    const description = 'https://zoom.us/j/987654321';

    expect(extractConferenceUrl(description), 'https://zoom.us/j/987654321');
  });

  test('extracts a Microsoft Teams link', () {
    const description =
        'Microsoft Teams meeting\n'
        'https://teams.microsoft.com/l/meetup-join/19%3ameeting_abc%40thread.v2/0';

    expect(
      extractConferenceUrl(description),
      'https://teams.microsoft.com/l/meetup-join/19%3ameeting_abc%40thread.v2/0',
    );
  });

  test('a description with no conference link returns null', () {
    const description = 'Just a regular meeting, no video call.';

    expect(extractConferenceUrl(description), isNull);
  });

  test('a null description returns null', () {
    expect(extractConferenceUrl(null), isNull);
  });

  test('when two links are present, the earlier one in the text wins', () {
    const description =
        'Backup: https://us02web.zoom.us/j/111111111\n'
        'Primary: https://meet.google.com/abc-defg-hij';

    expect(
      extractConferenceUrl(description),
      'https://us02web.zoom.us/j/111111111',
    );
  });

  test('the description is returned unchanged in every case', () {
    const withLink = 'Join: https://meet.google.com/abc-defg-hij';
    const withoutLink = 'No link here.';

    extractConferenceUrl(withLink);
    extractConferenceUrl(withoutLink);

    expect(withLink, 'Join: https://meet.google.com/abc-defg-hij');
    expect(withoutLink, 'No link here.');
  });
}
