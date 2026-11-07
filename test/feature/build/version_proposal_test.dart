import 'package:flutter_test/flutter_test.dart';
import 'package:stelaris/api/service/generator/generator_models.dart';
import 'package:stelaris/feature/build/publish/version_proposal.dart';

VersionProposal _propose(
  List<String> published, {
  ReleaseChannel channel = ReleaseChannel.release,
  BumpPart bump = BumpPart.patch,
}) => proposeVersion(channel: channel, bump: bump, published: published);

PublishedVersion _version(String version) => PublishedVersion(
  version: version,
  channel: version.endsWith('-SNAPSHOT')
      ? ReleaseChannel.snapshot
      : ReleaseChannel.release,
  coordinates: 'g:a:$version',
  repositoryUrl: 'https://repo.test',
);

void main() {
  group('proposeVersion', () {
    test('the first release is 0.1.0', () {
      expect(_propose([]), const ProposedVersion('0.1.0'));
    });

    test('the first snapshot is 0.1.0-SNAPSHOT', () {
      expect(
        _propose([], channel: ReleaseChannel.snapshot),
        const ProposedVersion('0.1.0-SNAPSHOT'),
      );
    });

    test('patch and minor bump the latest release', () {
      expect(_propose(['1.4.2']), const ProposedVersion('1.4.3'));
      expect(
        _propose(['1.4.2'], bump: BumpPart.minor),
        const ProposedVersion('1.5.0'),
      );
    });

    test('major resets minor and patch', () {
      expect(
        _propose(['1.4.2'], bump: BumpPart.major),
        const ProposedVersion('2.0.0'),
      );
    });

    test('a snapshot is the release proposal with -SNAPSHOT', () {
      expect(
        _propose(
          ['1.4.2'],
          channel: ReleaseChannel.snapshot,
          bump: BumpPart.minor,
        ),
        const ProposedVersion('1.5.0-SNAPSHOT'),
      );
    });

    test('snapshots are not the base of the proposal', () {
      expect(
        _propose(['1.4.2', '2.0.0-SNAPSHOT']),
        const ProposedVersion('1.4.3'),
      );
      expect(_propose(['0.3.0-SNAPSHOT']), const ProposedVersion('0.1.0'));
    });

    test('the latest release is the numerically highest', () {
      expect(
        _propose(['1.9.0', '1.10.0', '1.2.0']),
        const ProposedVersion('1.10.1'),
      );
    });

    test('an unreadable version is reported instead of thrown', () {
      for (final raw in ['1.0', '1.0.0-dev.1', '01.2.3', 'latest', '']) {
        expect(_propose(['1.0.0', raw]), UnreadableVersion(raw), reason: raw);
      }
    });
  });

  group('customVersion', () {
    test('a custom release is the version as typed', () {
      expect(customVersion('1.2.3', ReleaseChannel.release), '1.2.3');
    });

    test('a custom snapshot gets -SNAPSHOT appended', () {
      expect(customVersion('1.2.3', ReleaseChannel.snapshot), '1.2.3-SNAPSHOT');
    });

    test('anything but X.Y.Z is not a custom version', () {
      for (final raw in [
        '',
        '1.2',
        '1.2.3.4',
        '01.2.3',
        '1.2.03',
        'v1.2.3',
        '1.2.3-SNAPSHOT',
        '1.2.3 ',
      ]) {
        expect(
          customVersion(raw, ReleaseChannel.release),
          isNull,
          reason: 'release "$raw"',
        );
        expect(
          customVersion(raw, ReleaseChannel.snapshot),
          isNull,
          reason: 'snapshot "$raw"',
        );
      }
    });

    test('the release number drops -SNAPSHOT only', () {
      expect(releaseNumber('0.3.0-SNAPSHOT'), '0.3.0');
      expect(releaseNumber('0.3.0'), '0.3.0');
    });
  });

  test('newestFirst puts a release above its snapshot', () {
    final sorted = newestFirst([
      _version('1.4.2'),
      _version('1.5.0-SNAPSHOT'),
      _version('1.5.0'),
      _version('1.10.0'),
    ]);

    expect(sorted.map((it) => it.version), [
      '1.10.0',
      '1.5.0',
      '1.5.0-SNAPSHOT',
      '1.4.2',
    ]);
  });

  test('newestFirst puts unreadable versions last', () {
    final sorted = newestFirst([_version('weird'), _version('0.1.0')]);

    expect(sorted.map((it) => it.version), ['0.1.0', 'weird']);
  });
}
