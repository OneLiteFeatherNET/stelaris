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
