<?php


function sanitize($conn, $value) {
    return $conn->real_escape_string(trim($value));
}

function redirect($path) {
    header("Location: " . BASE_URL . $path);
    exit();
}

function logActivity($conn, $userId, $action, $description = '') {
    $action = sanitize($conn, $action);
    $description = sanitize($conn, $description);
    $conn->query("INSERT INTO activity_logs (user_id, action, description) VALUES ('$userId', '$action', '$description')");
}

function formatMoney($amount) {
    return number_format((float)$amount, 2);
}

function roleName($roleId) {
    switch ((int)$roleId) {
        case ROLE_ADMIN: return 'Admin';
        case ROLE_BRANCH_MANAGER: return 'Branch Manager';
        case ROLE_SALES_USER: return 'Sales User';
        default: return 'Unknown';
    }
}


function getStockQty($conn, $productId, $branchId) {
    $stmt = $conn->prepare("SELECT quantity FROM inventory WHERE product_id = ? AND branch_id = ?");
    $stmt->bind_param("ii", $productId, $branchId);
    $stmt->execute();
    $res = $stmt->get_result();
    if ($row = $res->fetch_assoc()) {
        return (int)$row['quantity'];
    }
    return 0;
}

function adjustStock($conn, $productId, $branchId, $delta) {
    $current = getStockQty($conn, $productId, $branchId);
    $exists = $current !== null;
    $stmt = $conn->prepare("SELECT inventory_id FROM inventory WHERE product_id = ? AND branch_id = ?");
    $stmt->bind_param("ii", $productId, $branchId);
    $stmt->execute();
    $res = $stmt->get_result();
    if ($res->num_rows > 0) {
        $upd = $conn->prepare("UPDATE inventory SET quantity = quantity + ? WHERE product_id = ? AND branch_id = ?");
        $upd->bind_param("iii", $delta, $productId, $branchId);
        $upd->execute();
    } else {
        $ins = $conn->prepare("INSERT INTO inventory (product_id, branch_id, quantity) VALUES (?, ?, ?)");
        $ins->bind_param("iii", $productId, $branchId, $delta);
        $ins->execute();
    }
}

function checkLowStock($conn, $productId, $branchId) {
    $qty = getStockQty($conn, $productId, $branchId);
    $stmt = $conn->prepare("SELECT product_name, reorder_level FROM products WHERE product_id = ?");
    $stmt->bind_param("i", $productId);
    $stmt->execute();
    $product = $stmt->get_result()->fetch_assoc();
    if ($product && $qty <= (int)$product['reorder_level']) {
        $msg = "Low stock: " . $product['product_name'] . " (" . $qty . " left)";
        $msgEsc = sanitize($conn, $msg);
        $conn->query("INSERT INTO notifications (product_id, branch_id, message) VALUES ('$productId', '$branchId', '$msgEsc')");
    }
}

function flash($type, $message) {
    $_SESSION['flash'] = ['type' => $type, 'message' => $message];
}

function getFlash() {
    if (isset($_SESSION['flash'])) {
        $f = $_SESSION['flash'];
        unset($_SESSION['flash']);
        return $f;
    }
    return null;
}
