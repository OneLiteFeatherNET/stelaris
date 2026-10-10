# Changelog

## [1.6.0](https://github.com/OneLiteFeatherNET/stelaris/compare/v1.5.0...v1.6.0) (2026-10-10)


### Features

* **app:** improve layout ([3f1cefb](https://github.com/OneLiteFeatherNET/stelaris/commit/3f1cefb81d992d4d277facde878798ebcd33c53a))
* **auth:** sign in with OpenID Connect ([#178](https://github.com/OneLiteFeatherNET/stelaris/issues/178)) ([e20a294](https://github.com/OneLiteFeatherNET/stelaris/commit/e20a2948fdbc731fe8050e220995d0816cd9e7a6))
* **copy:** add option to copy models ([#207](https://github.com/OneLiteFeatherNET/stelaris/issues/207)) ([ca07df9](https://github.com/OneLiteFeatherNET/stelaris/commit/ca07df933bbf64d30c5da0f41b7bb5e7a3a172a8))
* **detail:** merge single-field tabs and give tabs stable ids ([#198](https://github.com/OneLiteFeatherNET/stelaris/issues/198)) ([99721ee](https://github.com/OneLiteFeatherNET/stelaris/commit/99721eea6f1f7259333f54310a6f19c62d316c49))
* **dialog:** add name confirmation to delete a model ([#183](https://github.com/OneLiteFeatherNET/stelaris/issues/183)) ([615e08d](https://github.com/OneLiteFeatherNET/stelaris/commit/615e08df6a8e4fb0b0cb0d8260cfe0be12d0292f))
* **input:** suggest minecraft materials in id fields ([#219](https://github.com/OneLiteFeatherNET/stelaris/issues/219)) ([2ff36a5](https://github.com/OneLiteFeatherNET/stelaris/commit/2ff36a5afeaad126d3d8c591625421842d9bcc7e))
* **item:** add component usage ([#210](https://github.com/OneLiteFeatherNET/stelaris/issues/210)) ([8e8d78f](https://github.com/OneLiteFeatherNET/stelaris/commit/8e8d78f57f5db8394d86c406870872eb4ac68b9a))
* **model:** add info chip widget ([#182](https://github.com/OneLiteFeatherNET/stelaris/issues/182)) ([192f589](https://github.com/OneLiteFeatherNET/stelaris/commit/192f589489f29a6096f6447c4a6ecc6c48c2d86f))
* **model:** add info dialog ([#181](https://github.com/OneLiteFeatherNET/stelaris/issues/181)) ([3e04f0f](https://github.com/OneLiteFeatherNET/stelaris/commit/3e04f0f323d317d5ae1503e2bdcbd8a40ef1350a))
* **model:** overhaul comment field ([#197](https://github.com/OneLiteFeatherNET/stelaris/issues/197)) ([0c0c9fe](https://github.com/OneLiteFeatherNET/stelaris/commit/0c0c9feff7773539f808fb5f263481f1a222cfd1))
* **navigation:** draw the rail icons from Minecraft ([#190](https://github.com/OneLiteFeatherNET/stelaris/issues/190)) ([1758a1f](https://github.com/OneLiteFeatherNET/stelaris/commit/1758a1f13ae7d83188907be66bf8572549f6c1ad))
* **navigation:** draw the rail icons from Minecraft ([#191](https://github.com/OneLiteFeatherNET/stelaris/issues/191)) ([1758a1f](https://github.com/OneLiteFeatherNET/stelaris/commit/1758a1f13ae7d83188907be66bf8572549f6c1ad))
* **page:** add note usage to attributes and sound entities ([#203](https://github.com/OneLiteFeatherNET/stelaris/issues/203)) ([47766db](https://github.com/OneLiteFeatherNET/stelaris/commit/47766db2a32daa859209396957f737ade1f5b657))
* **palette:** run commands and jump anywhere with Ctrl+K ([#192](https://github.com/OneLiteFeatherNET/stelaris/issues/192)) ([61907ab](https://github.com/OneLiteFeatherNET/stelaris/commit/61907ab17b2fb255f501fbd5644f5753b3b414de))
* **search:** overhauled search logic and widget ([#185](https://github.com/OneLiteFeatherNET/stelaris/issues/185)) ([85a2c77](https://github.com/OneLiteFeatherNET/stelaris/commit/85a2c77ed378f7925ea444fb21f14bdf6dec5844))
* **state:** improve async redux flow and stability ([#173](https://github.com/OneLiteFeatherNET/stelaris/issues/173)) ([ddf8c30](https://github.com/OneLiteFeatherNET/stelaris/commit/ddf8c3044de81c22a7f8d6c3adfbd4d495411875))


### Bug Fixes

* **action:** avoid double model copy ([#184](https://github.com/OneLiteFeatherNET/stelaris/issues/184)) ([e0ccb2e](https://github.com/OneLiteFeatherNET/stelaris/commit/e0ccb2e82b2466ca55d19835866c30e8b9b7ef6f))
* **app:** remove reference to missing SmoothWheelBinding ([8a218e8](https://github.com/OneLiteFeatherNET/stelaris/commit/8a218e8098c48cabb2f29bc7b71d2a404b1faa4b))
* **chip:** increase fontSize by one ([5e8d2de](https://github.com/OneLiteFeatherNET/stelaris/commit/5e8d2dec2dac7b5cfe10f4067a6eb41d79141bc3))
* **command:** improve button sizing ([b658b4d](https://github.com/OneLiteFeatherNET/stelaris/commit/b658b4d71e21a6a6911e25fbdb2fa7545b290364))
* **command:** improve widget spacing ([#180](https://github.com/OneLiteFeatherNET/stelaris/issues/180)) ([63ddfc9](https://github.com/OneLiteFeatherNET/stelaris/commit/63ddfc91e9905200571a0cd522995bb1862ae0c8))
* **deps:** update dependency async_redux to ^29.2.2 ([#217](https://github.com/OneLiteFeatherNET/stelaris/issues/217)) ([6ee2728](https://github.com/OneLiteFeatherNET/stelaris/commit/6ee27282b6576eeeee7b3e2fc885dca203c80a6e))
* **deps:** update dependency async_redux to v29 ([#208](https://github.com/OneLiteFeatherNET/stelaris/issues/208)) ([0255a5d](https://github.com/OneLiteFeatherNET/stelaris/commit/0255a5d40a060109b55899276e34099f14328bcd))
* **deps:** update dependency go_router to ^18.0.2 ([#196](https://github.com/OneLiteFeatherNET/stelaris/issues/196)) ([8088a45](https://github.com/OneLiteFeatherNET/stelaris/commit/8088a458a43f1933fb2b2f8c5fea590b1b353ea3))
* **deps:** update dependency material_ui to ^1.5.0 ([#201](https://github.com/OneLiteFeatherNET/stelaris/issues/201)) ([1707939](https://github.com/OneLiteFeatherNET/stelaris/commit/170793959faed00d295cecc5002fbd4ff56167d1))
* **deps:** update dependency url_launcher to ^6.3.3 ([#206](https://github.com/OneLiteFeatherNET/stelaris/issues/206)) ([42f2ce3](https://github.com/OneLiteFeatherNET/stelaris/commit/42f2ce39dcbce6d7d75e84e747dbe2be7f3f4c20))
* **dialog:** improve color usage between themes ([7271b22](https://github.com/OneLiteFeatherNET/stelaris/commit/7271b227ef03211f76d998ad3f5a0de2983b4bd4))
* **enchantment:** limit level input to the maximum of a short ([#193](https://github.com/OneLiteFeatherNET/stelaris/issues/193)) ([8642e67](https://github.com/OneLiteFeatherNET/stelaris/commit/8642e676614be3dd65d47e3279555c98f20d802f))
* **input:** allow clearing text fields and ignore unchanged values ([6569e80](https://github.com/OneLiteFeatherNET/stelaris/commit/6569e8016a4bc27933290b17c9b3926bd30677cd))
* **input:** stop input filters from dropping valid characters ([5320d1a](https://github.com/OneLiteFeatherNET/stelaris/commit/5320d1ae5e0a8cb572ac5f8c57e67c160f3ec48b))
* **item:** improve component loading ([#212](https://github.com/OneLiteFeatherNET/stelaris/issues/212)) ([0108214](https://github.com/OneLiteFeatherNET/stelaris/commit/010821488df6a9d2f32d5f21614e8e59b0f958e1))
* **page:** add missing padding ([78fc357](https://github.com/OneLiteFeatherNET/stelaris/commit/78fc3577b12daa7324cca8fbf7d5680082bb9275))
* **problem:** migrate to freezed model to avoid equality and other issues ([c7a52f2](https://github.com/OneLiteFeatherNET/stelaris/commit/c7a52f2c631a1b4ebe027b187234dbc53568410e))
* **setting:** use outlined icon instead of the regular variant ([3fb39f7](https://github.com/OneLiteFeatherNET/stelaris/commit/3fb39f796dfa28f9257fcd798e4820eb1a0fbe88))
* **state:** avoid naming typo and add error resilience ([08c567a](https://github.com/OneLiteFeatherNET/stelaris/commit/08c567aee0bf4524a602443bcdc415f55bbfdc0e))
* **theme:** improve text theme copy to avoid black text ([7b52e7c](https://github.com/OneLiteFeatherNET/stelaris/commit/7b52e7c68906a46622a7c0487f59b57baac4a228))


### Performance Improvements

* **advancement:** rebuild the detail page only when its data changes ([11dbd43](https://github.com/OneLiteFeatherNET/stelaris/commit/11dbd431cd32e47bae55af8ef0c6ac62aaa76c45))

## [1.5.0](https://github.com/OneLiteFeatherNET/stelaris/compare/v1.4.1...v1.5.0) (2026-09-14)


### Features

* **error:** add problem detail handling ([#169](https://github.com/OneLiteFeatherNET/stelaris/issues/169)) ([d77de65](https://github.com/OneLiteFeatherNET/stelaris/commit/d77de65396b6e128ac01a460c38a909cbb8261a4))
* **model:** add key field ([#162](https://github.com/OneLiteFeatherNET/stelaris/issues/162)) ([53883f5](https://github.com/OneLiteFeatherNET/stelaris/commit/53883f540590592bdc74e8dd110467530146661b))

## [1.4.1](https://github.com/OneLiteFeatherNET/stelaris/compare/v1.4.0...v1.4.1) (2026-09-14)


### Bug Fixes

* **model:** use hoverEffect from Material 3 ([#168](https://github.com/OneLiteFeatherNET/stelaris/issues/168)) ([e40be73](https://github.com/OneLiteFeatherNET/stelaris/commit/e40be73548e71713453b69a3f45bc011e3cda0c8))
* **route:** add usage of ShellRoute ([#167](https://github.com/OneLiteFeatherNET/stelaris/issues/167)) ([2bde2db](https://github.com/OneLiteFeatherNET/stelaris/commit/2bde2db9185b1857b055dd2012c964ee31c60509))
* **tab:** improve focus traversal ([#165](https://github.com/OneLiteFeatherNET/stelaris/issues/165)) ([69f12b2](https://github.com/OneLiteFeatherNET/stelaris/commit/69f12b29d3d05b22a0df5674bee2efeadc22a595))
* **view:** use horizontal spacing instead of vertical ([6d68b31](https://github.com/OneLiteFeatherNET/stelaris/commit/6d68b313c898bf091e0cbdd43da3b638249952bd))

## [1.4.0](https://github.com/OneLiteFeatherNET/stelaris/compare/v1.3.3...v1.4.0) (2026-09-05)


### Features

* **project:** allow the edit of projects ([#149](https://github.com/OneLiteFeatherNET/stelaris/issues/149)) ([13bc128](https://github.com/OneLiteFeatherNET/stelaris/commit/13bc128a0d4816a28072ed9e925101bdc105fa7f))


### Bug Fixes

* **deps:** update dependency dio to ^5.11.1 ([#155](https://github.com/OneLiteFeatherNET/stelaris/issues/155)) ([8d98de3](https://github.com/OneLiteFeatherNET/stelaris/commit/8d98de39be232c694bd00b623711c8bae5fbaf3a))
* **deps:** update patch updates ([6e42dce](https://github.com/OneLiteFeatherNET/stelaris/commit/6e42dce3aefaa104f9b58f6f119fe9db462f08dc))
* **deps:** update patch updates (patch) ([#154](https://github.com/OneLiteFeatherNET/stelaris/issues/154)) ([6e42dce](https://github.com/OneLiteFeatherNET/stelaris/commit/6e42dce3aefaa104f9b58f6f119fe9db462f08dc))
* **project:** redirect to project selection if no project is selected ([#156](https://github.com/OneLiteFeatherNET/stelaris/issues/156)) ([64c4c98](https://github.com/OneLiteFeatherNET/stelaris/commit/64c4c98d874e16618bb872222d411858f23b6d83))

## [1.3.3](https://github.com/OneLiteFeatherNET/stelaris/compare/v1.3.2...v1.3.3) (2026-08-27)


### Bug Fixes

* **font:** add projectId to font deletion ([#147](https://github.com/OneLiteFeatherNET/stelaris/issues/147)) ([bbe35f6](https://github.com/OneLiteFeatherNET/stelaris/commit/bbe35f60f028dcdf8a7035862150159e5826c3d3))

## [1.3.2](https://github.com/OneLiteFeatherNET/stelaris/compare/v1.3.1...v1.3.2) (2026-08-26)


### Bug Fixes

* **ci:** publish the Helm chart only after the image ([#136](https://github.com/OneLiteFeatherNET/stelaris/issues/136)) ([a942da4](https://github.com/OneLiteFeatherNET/stelaris/commit/a942da42c4b2c648e674317b00fed2c83fc707dc))
* **item:** implement missing lore reorder ([#146](https://github.com/OneLiteFeatherNET/stelaris/issues/146)) ([54a8393](https://github.com/OneLiteFeatherNET/stelaris/commit/54a839344cef5d74999184e751d021508b62f70e))
* **project:** improve regex handling for project key input ([#143](https://github.com/OneLiteFeatherNET/stelaris/issues/143)) ([c062e22](https://github.com/OneLiteFeatherNET/stelaris/commit/c062e222ce53e544fce838424bdff63b089acace))

## [1.3.1](https://github.com/OneLiteFeatherNET/stelaris/compare/v1.3.0...v1.3.1) (2026-08-25)


### Bug Fixes

* **build:** send projectId when downloading a generated code base ([#134](https://github.com/OneLiteFeatherNET/stelaris/issues/134)) ([6e36c5d](https://github.com/OneLiteFeatherNET/stelaris/commit/6e36c5d4a3a8f85af46d37e59294c929ae76efe7))

## [1.3.0](https://github.com/OneLiteFeatherNET/stelaris/compare/v1.2.0...v1.3.0) (2026-08-24)


### Features

* **project:** add switch dialog ([a3b357e](https://github.com/OneLiteFeatherNET/stelaris/commit/a3b357ed7db710eac0698dfa0b197fb08b901c80))

## [1.2.0](https://github.com/OneLiteFeatherNET/stelaris/compare/v1.1.1...v1.2.0) (2026-08-24)


### Features

* wire project id into models ([#129](https://github.com/OneLiteFeatherNET/stelaris/issues/129)) ([de79215](https://github.com/OneLiteFeatherNET/stelaris/commit/de792153025a83a5abb7bb1117f5d457a42c44e4))

## [1.1.1](https://github.com/OneLiteFeatherNET/stelaris/compare/v1.1.0...v1.1.1) (2026-08-23)


### Bug Fixes

* **docker:** make the deployed image actually boot ([#128](https://github.com/OneLiteFeatherNET/stelaris/issues/128)) ([54f63b6](https://github.com/OneLiteFeatherNET/stelaris/commit/54f63b69ee2fe42c2f5e46ab5b36a40d5f8d4012))

## [1.1.0](https://github.com/OneLiteFeatherNET/stelaris/compare/v1.0.0...v1.1.0) (2026-08-23)


### Features

* **api:** add project client and wire api calls ([#123](https://github.com/OneLiteFeatherNET/stelaris/issues/123)) ([7411369](https://github.com/OneLiteFeatherNET/stelaris/commit/74113691cd2db1b787c35dbdf9bcf46a3dadc679))
* **deferred:** add defferred load ([#114](https://github.com/OneLiteFeatherNET/stelaris/issues/114)) ([54b21c1](https://github.com/OneLiteFeatherNET/stelaris/commit/54b21c1a2f3a8a6df995bd10dce5625884b2acfa))
* **docker:** serve the web bundle from a hardened nginx image ([#124](https://github.com/OneLiteFeatherNET/stelaris/issues/124)) ([d506f6a](https://github.com/OneLiteFeatherNET/stelaris/commit/d506f6a635c68aebe75b76255ab3297fcfb50949))
* **helm:** add a chart that deploys the UI to Kubernetes ([#125](https://github.com/OneLiteFeatherNET/stelaris/issues/125)) ([ac6a025](https://github.com/OneLiteFeatherNET/stelaris/commit/ac6a025dd801933554e388efb2bfe08a9392555a))
* **release:** version pubspec, the app and the chart from one release ([#127](https://github.com/OneLiteFeatherNET/stelaris/issues/127)) ([cccc85f](https://github.com/OneLiteFeatherNET/stelaris/commit/cccc85f0fc9c53670152ba883b7156f1bd0c344b))


### Bug Fixes

* avoid deprecated code parts ([#122](https://github.com/OneLiteFeatherNET/stelaris/issues/122)) ([edf0309](https://github.com/OneLiteFeatherNET/stelaris/commit/edf030933b3c8067f945263826be6d4b05cf7d0e))
