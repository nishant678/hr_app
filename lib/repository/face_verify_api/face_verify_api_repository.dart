abstract class FaceVerifyApiRepository {
  Future<bool> isFaceRegistered();
  Future<void> registerFace(String imagePath);
}