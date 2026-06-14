import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:restic_movil/app/data/models/login_response.dart';
import 'package:restic_movil/app/data/services/storage_service.dart';
import 'package:restic_movil/app/routes/app_routes.dart';

/*
  modal para mostar las sucursales asociadas al usuario
*/
class BranchSelectionModal {
  static void show(List<Branch> branches, StorageService storageService) {
    Get.bottomSheet(
      Container(
        padding: const EdgeInsets.all(16),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(20),
            topRight: Radius.circular(20),
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Seleccione una sucursal',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            Flexible(
              child: ListView.separated(
                shrinkWrap: true,
                itemCount: branches.length,
                separatorBuilder: (_, __) => const Divider(),
                itemBuilder: (context, index) {
                  final branch = branches[index];
                  return ListTile(
                    leading: const Icon(Icons.store, color: Colors.blue),
                    title: Text(branch.name ?? 'Sucursal sin nombre'),
                    onTap: () async {
                      if (branch.id != null) {
                        await storageService.saveBranchId(branch.id!);
                        if (Get.isBottomSheetOpen ?? false) {
                          Get.back();
                        }
                        Get.offAllNamed(Routes.HOME);
                      }
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
      isDismissible: false,
      enableDrag: false,
    );
  }
}
