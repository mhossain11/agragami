import 'package:Agragami/admin/home/controller/admin_home_controller.dart';
import 'package:Agragami/admin/home/data/admin_home_repository.dart';
import 'package:flutter_test/flutter_test.dart';

/// Offline fake - the tap logic never touches it; the controller is
/// constructed directly (no Get.put), so onInit / Firebase never run.
class FakeAdminHomeRepository implements AdminHomeRepository {
  @override
  Future<int> getTotalUserCount(String roleName) async => 0;

  @override
  Stream<int> watchAllUsersTotalAmount() => const Stream<int>.empty();

  @override
  Stream<String> watchProfileImage(String userDocId) =>
      const Stream<String>.empty();

  @override
  Future<void> logout() async {}
}

void main() {
  group('showDeleteAllMoneyButton (Developer Screen 3-tap unlock)', () {
    test('tap 1 shows "click 1", tap 2 shows "click 2" - still locked', () {
      final controller =
          AdminHomeController(repository: FakeAdminHomeRepository());

      expect(controller.showDeleteAllMoneyButton.value, false);
      expect(controller.onDeveloperSecretTap(), 'click 1');
      expect(controller.showDeleteAllMoneyButton.value, false);
      expect(controller.onDeveloperSecretTap(), 'click 2');
      expect(controller.showDeleteAllMoneyButton.value, false);
    });

    test('3rd tap shows "delete button open" - unlocks and resets counter',
        () {
      final controller =
          AdminHomeController(repository: FakeAdminHomeRepository());

      controller.onDeveloperSecretTap(); // click 1
      controller.onDeveloperSecretTap(); // click 2
      expect(controller.onDeveloperSecretTap(), 'delete button open');
      expect(controller.showDeleteAllMoneyButton.value, true);

      // Counter was reset: the cycle restarts at "click 1" and the flag
      // never goes back to false.
      expect(controller.onDeveloperSecretTap(), 'click 1');
      expect(controller.showDeleteAllMoneyButton.value, true);
      expect(controller.onDeveloperSecretTap(), 'click 2');
      expect(controller.onDeveloperSecretTap(), 'delete button open');
      expect(controller.showDeleteAllMoneyButton.value, true);
    });

    test('flag stays true through further complete tap cycles', () {
      final controller =
          AdminHomeController(repository: FakeAdminHomeRepository());

      for (var i = 0; i < 9; i++) {
        controller.onDeveloperSecretTap();
      }
      expect(controller.showDeleteAllMoneyButton.value, true);
    });

    test('starts false - the button is hidden until unlocked', () {
      final controller =
          AdminHomeController(repository: FakeAdminHomeRepository());
      expect(controller.showDeleteAllMoneyButton.value, false);
    });

    test('hideDeleteAllMoneyButton hides it and resets the tap counter', () {
      final controller =
          AdminHomeController(repository: FakeAdminHomeRepository());

      controller.onDeveloperSecretTap(); // click 1
      controller.onDeveloperSecretTap(); // click 2
      expect(controller.onDeveloperSecretTap(), 'delete button open');
      expect(controller.showDeleteAllMoneyButton.value, true);

      controller.hideDeleteAllMoneyButton();
      expect(controller.showDeleteAllMoneyButton.value, false);

      // Counter was reset too: a fresh cycle starts at "click 1".
      expect(controller.onDeveloperSecretTap(), 'click 1');
      expect(controller.showDeleteAllMoneyButton.value, false);

      // Hiding again while already hidden is a safe no-op.
      controller.hideDeleteAllMoneyButton();
      expect(controller.showDeleteAllMoneyButton.value, false);
    });
  });
}
