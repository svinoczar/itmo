<?php
    $initial_time = microtime(true);
    $x = floatval($_POST["x_field"]);
    $y = floatval($_POST["y_field"]);
    $R = floatval($_POST["R_value"]);
    $executionTime = $initial_time - $_SERVER['REQUEST_TIME'];

    function validate($x, $y, $R){
        if(-4 <= $x && $x <= 4 && -3 <= $y && $y <= 5 && 1 <= $R && $R <= 5){
            return true;
        }
        return false;
    }

    function checkDot ($x, $y, $R) {
        if ($x < $R and $x > 0 and $y > 0 and $y < 0.5 * $R and $y >= 2 / $R * abs($x)) {
            return true;
        }
        if ($x < $R and $x > 0 and $y < 0 and $y > -0.5 * $R) {
            return true;
        }
        $dist  = sqrt($x**2 + $y**2);
        if($dist < $R and $x<0 and $y<0){
            return true;
        }
        return false;
    }


    if(validate($x, $y, $R)){
        $Collision = checkDot($x, $y, $R);

        if($Collision){
            $res = "true";
        } else {
            $res = "false";
        }

        $data = array('collision' => $res, 'exectime' => $executionTime);

        echo json_encode($data);
        http_response_code(201);
    } else {
        echo json_encode(array('collision' => "некорректные данные", 'exectime' => NULL));
        http_response_code(400);
    }



    function test1 ($x, $y, $R) {
        if (checkDot($x, $y, $R)){
            print("KAIF");
        } else {
            print("NE KAIF");
        }
        print("\n");
    }
    
    // test1(1,1,3)
?>