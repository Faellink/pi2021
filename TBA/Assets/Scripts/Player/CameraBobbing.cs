using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class CameraBobbing : MonoBehaviour
{

    [Header("Transform references")]
    public Transform headTransform;
    public Transform cameraTransform;

    [Header("Head bobbing")]
    public float bobFrequency = 5f;
    public float bobHorizontalAmplitude = 0.1f;
    public float bobVerticalAmplitude = 0.1f;
    [Range(0,1)] public float headBobSmoothing = 0.1f;

    //State
    public bool isWalking;
    private float walkingTime;
    private Vector3 targetCameraPosition;

    public Pause pause;

    // Start is called before the first frame update
    void Start()
    {
        
    }

    // Update is called once per frame
    void Update()
    {
        
        if(!isWalking){
            walkingTime = 0f;
        }else{
            walkingTime += Time.deltaTime;
        }

        targetCameraPosition = headTransform.position + CalculateHeadBobOffset(walkingTime);

        cameraTransform.position = Vector3.Lerp(cameraTransform.position, targetCameraPosition, headBobSmoothing);
        if((cameraTransform.position - targetCameraPosition).magnitude <= 0.001) cameraTransform.position = targetCameraPosition;

    }

    private Vector3 CalculateHeadBobOffset(float t){
        float horizontalOffset = 0;
        float verticalOffset = 0;
        Vector3 offset = Vector3.zero;

        if(t>0){
            horizontalOffset = Mathf.Cos(t * bobFrequency) * bobHorizontalAmplitude;
            verticalOffset = Mathf.Sin(t * bobFrequency * 2) * bobVerticalAmplitude;

            offset = headTransform.right * horizontalOffset + headTransform.up * verticalOffset;
        }
        return offset;
    }
}
