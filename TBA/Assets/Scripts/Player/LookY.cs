using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class LookY : MonoBehaviour
{

    public float mouseSensitivity = 100f;

    // Start is called before the first frame update
    void Start()
    {
        
    }

    // Update is called once per frame
    void Update()
    {
        float mouseY = Input.GetAxis("Mouse Y") * mouseSensitivity;



        Vector3 newRotation = transform.localEulerAngles;
        newRotation.x -= mouseY;

        transform.localEulerAngles = newRotation;

    }
}
