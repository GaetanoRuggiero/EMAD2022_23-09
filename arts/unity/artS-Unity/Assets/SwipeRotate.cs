using System;
using System.Globalization;
using FlutterUnityIntegration;
using UnityEngine;

public class SwipeRotate : MonoBehaviour
{
    [SerializeField]
    public float speed;

    // Start is called before the first frame update
    void Start()
    {
        speed = 40;
    }

    // Update is called once per frame
    void Update()
    {
        if (speed != 0) {
            gameObject.transform.Rotate(0f, Time.deltaTime * (-speed), 0f);
        }
        
    }

    public void SetRotationSpeed(String message)
    {
        float value = float.Parse(message, CultureInfo.InvariantCulture);
        speed = value;
        UnityMessageManager.Instance.SendMessageToFlutter("Rotation speed: " + speed.ToString());
    }
}
