<?php
header('Access-Control-Allow-Origin: *');
header('Content-Type: application/json');
require_once '../config/database.php';

error_reporting(E_ALL);
ini_set('display_errors', 1);

$database = new Database();
$conn = $database->getConnection();

if (!$conn) {
    http_response_code(500);
    echo json_encode(['success' => false, 'message' => 'Database connection failed']);
    exit();
}

$input = json_decode(file_get_contents('php://input'), true);

if (
    !isset($input['id']) ||
    !isset($input['user_id'])
) {
    http_response_code(400);
    echo json_encode(['success' => false, 'message' => 'Parameter tidak lengkap!']);
    exit();
}

$plant_id = intval($input['id']);
$user_id = intval($input['user_id']);

try {
    // Mulai transaksi
    $conn->beginTransaction();
    
    // Hapus jadwal terkait terlebih dahulu (meskipun ada CASCADE, lebih aman)
    $deleteSchedulesQuery = "DELETE FROM schedules WHERE plant_id = :plant_id AND user_id = :user_id";
    $scheduleStmt = $conn->prepare($deleteSchedulesQuery);
    $scheduleStmt->bindParam(':plant_id', $plant_id, PDO::PARAM_INT);
    $scheduleStmt->bindParam(':user_id', $user_id, PDO::PARAM_INT);
    $scheduleStmt->execute();
    
    // Hapus tanaman
    $query = "DELETE FROM plants WHERE id = :id AND user_id = :user_id";
    $stmt = $conn->prepare($query);
    $stmt->bindParam(':id', $plant_id, PDO::PARAM_INT);
    $stmt->bindParam(':user_id', $user_id, PDO::PARAM_INT);
    $stmt->execute();

    if ($stmt->rowCount() > 0) {
        $conn->commit();
        echo json_encode(['success' => true, 'message' => 'Tanaman berhasil dihapus!']);
    } else {
        $conn->rollback();
        echo json_encode(['success' => false, 'message' => 'Data tidak ditemukan atau sudah dihapus.']);
    }
} catch (Exception $e) {
    $conn->rollback();
    error_log("Error deleting plant: " . $e->getMessage());
    http_response_code(500);
    
    // Berikan pesan error yang lebih user-friendly
    if (strpos($e->getMessage(), 'foreign key constraint') !== false || 
        strpos($e->getMessage(), 'FOREIGN KEY') !== false) {
        echo json_encode(['success' => false, 'message' => 'Tidak dapat menghapus tanaman karena masih memiliki jadwal aktif. Hapus jadwal terlebih dahulu.']);
    } else {
        echo json_encode(['success' => false, 'message' => 'Gagal menghapus tanaman. Silakan coba lagi.']);
    }
}
