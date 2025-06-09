<?php
header('Access-Control-Allow-Origin: *');
header('Content-Type: application/json');
require_once '../config/database.php';

error_reporting(E_ALL);
ini_set('display_errors', 1);

// Koneksi DB
$database = new Database();
$conn = $database->getConnection();

if (!$conn) {
    http_response_code(500);
    echo json_encode(['success' => false, 'message' => 'Database connection failed']);
    exit();
}

// Ambil body
$input = json_decode(file_get_contents('php://input'), true);

if (
    !isset($input['id']) ||
    !isset($input['repeat_type']) ||
    !isset($input['time']) ||
    !isset($input['reminder_enabled'])
) {
    http_response_code(400);
    echo json_encode(['success' => false, 'message' => 'Data tidak lengkap']);
    exit();
}

$id = intval($input['id']);
$repeat_type = trim($input['repeat_type']);
$time = trim($input['time']);
$reminder_enabled = intval($input['reminder_enabled']);

try {
    $query = "UPDATE schedules
              SET repeat_type = :repeat_type, time = :time, reminder_enabled = :reminder_enabled
              WHERE id = :id";
    $stmt = $conn->prepare($query);
    $stmt->bindParam(':repeat_type', $repeat_type);
    $stmt->bindParam(':time', $time);
    $stmt->bindParam(':reminder_enabled', $reminder_enabled, PDO::PARAM_INT);
    $stmt->bindParam(':id', $id, PDO::PARAM_INT);

    if ($stmt->execute()) {
        echo json_encode(['success' => true, 'message' => 'Jadwal berhasil diupdate']);
    } else {
        http_response_code(500);
        echo json_encode(['success' => false, 'message' => 'Gagal mengupdate jadwal']);
    }
} catch (Exception $e) {
    http_response_code(500);
    echo json_encode(['success' => false, 'message' => 'Error: ' . $e->getMessage()]);
}
?>
