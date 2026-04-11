// lib/modules/driver/controllers/incident_controller.dart

import 'dart:io';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:menahariya/core/services/api/api_client.dart';
import 'package:menahariya/core/utils/permissions/permission_handler.dart';

import '../../../core/utils/app_snackbar.dart';

class IncidentController extends GetxController {
  static IncidentController get instance => Get.find();

  final ApiClient _apiClient = ApiClient.instance;

  // Current trip ID
  late final String tripId;

  // Form controllers
  late final TextEditingController titleController;
  late final TextEditingController descriptionController;
  late final TextEditingController locationController;

  // Observables
  final _isLoading = false.obs;
  final _incidentType = Rxn<IncidentType>();
  final _severity = Rxn<IncidentSeverity>();
  final _attachments = <File>[].obs;
  final _isUploading = false.obs;
  final _incidentHistory = <Incident>[].obs;

  // Getters
  bool get isLoading => _isLoading.value;
  bool get isUploading => _isUploading.value;
  IncidentType? get incidentType => _incidentType.value;
  IncidentSeverity? get severity => _severity.value;
  List<File> get attachments => _attachments;
  List<Incident> get incidentHistory => _incidentHistory;

  // Predefined incident types
  final List<IncidentTypeInfo> incidentTypes = const [
    IncidentTypeInfo(
      type: IncidentType.accident,
      title: 'Accident',
      icon: Icons.car_crash_rounded,
      color: 'red',
    ),
    IncidentTypeInfo(
      type: IncidentType.mechanical,
      title: 'Mechanical Issue',
      icon: Icons.build_rounded,
      color: 'orange',
    ),
    IncidentTypeInfo(
      type: IncidentType.delay,
      title: 'Delay',
      icon: Icons.timer_rounded,
      color: 'yellow',
    ),
    IncidentTypeInfo(
      type: IncidentType.security,
      title: 'Security Issue',
      icon: Icons.security_rounded,
      color: 'purple',
    ),
    IncidentTypeInfo(
      type: IncidentType.passenger,
      title: 'Passenger Issue',
      icon: Icons.people_rounded,
      color: 'blue',
    ),
    IncidentTypeInfo(
      type: IncidentType.road,
      title: 'Road Condition',
      icon: Icons.alt_route,
      color: 'brown',
    ),
    IncidentTypeInfo(
      type: IncidentType.weather,
      title: 'Weather',
      icon: Icons.wb_sunny_rounded,
      color: 'amber',
    ),
    IncidentTypeInfo(
      type: IncidentType.other,
      title: 'Other',
      icon: Icons.more_horiz_rounded,
      color: 'grey',
    ),
  ];

  @override
  void onInit() {
    super.onInit();
    _getTripId();
    _initializeControllers();
    loadIncidentHistory();
  }

  void _getTripId() {
    final args = Get.arguments;
    if (args != null && args['tripId'] != null) {
      tripId = args['tripId'];
    }
  }

  void _initializeControllers() {
    titleController = TextEditingController();
    descriptionController = TextEditingController();
    locationController = TextEditingController();
  }

  Future<void> loadIncidentHistory() async {
    try {
      final response = await _apiClient.get(
        '/driver/incidents/$tripId',
      );

      if (response != null && response['data'] != null) {
        final List<dynamic> incidents = response['data'];
        _incidentHistory.value = incidents
            .map((i) => Incident.fromJson(i))
            .toList();
      }
    } catch (e) {
      print('Error loading incident history: $e');
    }
  }

  void setIncidentType(IncidentType type) {
    _incidentType.value = type;
  }

  void setSeverity(IncidentSeverity severity) {
    _severity.value = severity;
  }

  Future<void> pickImage() async {
    final granted = await PermissionHandler.requestCameraPermission();
    if (!granted) return;

    try {
      final picker = ImagePicker();
      final pickedFile = await picker.pickImage(
        source: ImageSource.camera,
        maxWidth: 1280,
        maxHeight: 720,
        imageQuality: 70,
      );

      if (pickedFile != null) {
        _attachments.add(File(pickedFile.path));
      }
    } catch (e) {
      print('Error picking image: $e');
      AppSnackbar.show(
        'Error',
        'Failed to capture image',
      );
    }
  }

  Future<void> pickImageFromGallery() async {
    final granted = await PermissionHandler.requestStoragePermission();
    if (!granted) return;

    try {
      final picker = ImagePicker();
      final pickedFile = await picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 1280,
        maxHeight: 720,
        imageQuality: 70,
      );

      if (pickedFile != null) {
        _attachments.add(File(pickedFile.path));
      }
    } catch (e) {
      print('Error picking image: $e');
      AppSnackbar.show(
        'Error',
        'Failed to pick image',
      );
    }
  }

  void removeAttachment(int index) {
    if (index >= 0 && index < _attachments.length) {
      _attachments.removeAt(index);
    }
  }

  Future<void> submitIncident() async {
    if (_incidentType.value == null) {
      AppSnackbar.show(
        'Error',
        'Please select incident type',
      );
      return;
    }

    if (titleController.text.isEmpty) {
      AppSnackbar.show(
        'Error',
        'Please enter incident title',
      );
      return;
    }

    try {
      _isLoading.value = true;

      // Prepare form data
      final formData = FormData({
        'tripId': tripId,
        'type': _incidentType.value!.index,
        'severity': _severity.value?.index ?? 1,
        'title': titleController.text,
        'description': descriptionController.text,
        'location': locationController.text,
        'timestamp': DateTime.now().toIso8601String(),
      });

      // Upload attachments
      for (var i = 0; i < _attachments.length; i++) {
        formData.files.add(MapEntry(
          'attachment_$i',
          await MultipartFile(
            File(_attachments[i].path),
            filename: _attachments[i].path.split('/').last,
          )
        ));
      }

      final response = await _apiClient.post(
        '/driver/report-incident',
        data: formData,
      );

      if (response != null && response['success'] == true) {
        AppSnackbar.show(
          'Success',
          'Incident reported successfully',
        );

        // Reset form
        clearForm();

        // Refresh history
        loadIncidentHistory();

        // Navigate back
        Get.back();
      }
    } catch (e) {
      print('Error submitting incident: $e');
      AppSnackbar.show(
        'Error',
        'Failed to report incident',
      );
    } finally {
      _isLoading.value = false;
    }
  }

  void clearForm() {
    _incidentType.value = null;
    _severity.value = null;
    titleController.clear();
    descriptionController.clear();
    locationController.clear();
    _attachments.clear();
  }

  @override
  void onClose() {
    titleController.dispose();
    descriptionController.dispose();
    locationController.dispose();
    super.onClose();
  }
}

enum IncidentType {
  accident,
  mechanical,
  delay,
  security,
  passenger,
  road,
  weather,
  other,
}

enum IncidentSeverity {
  low,
  medium,
  high,
  critical,
}

class IncidentTypeInfo {
  final IncidentType type;
  final String title;
  final IconData icon;
  final String color;

  const IncidentTypeInfo({
    required this.type,
    required this.title,
    required this.icon,
    required this.color,
  });
}

class Incident {
  final String id;
  final IncidentType type;
  final IncidentSeverity severity;
  final String title;
  final String description;
  final String? location;
  final DateTime timestamp;
  final List<String>? attachments;
  final String status;

  Incident({
    required this.id,
    required this.type,
    required this.severity,
    required this.title,
    required this.description,
    this.location,
    required this.timestamp,
    this.attachments,
    required this.status,
  });

  factory Incident.fromJson(Map<String, dynamic> json) {
    return Incident(
      id: json['id'],
      type: IncidentType.values[json['type']],
      severity: IncidentSeverity.values[json['severity']],
      title: json['title'],
      description: json['description'],
      location: json['location'],
      timestamp: DateTime.parse(json['timestamp']),
      attachments: json['attachments'] != null
          ? List<String>.from(json['attachments'])
          : null,
      status: json['status'],
    );
  }
}