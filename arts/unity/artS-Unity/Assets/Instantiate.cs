using System;
using FlutterUnityIntegration;
using UnityEngine;
using UnityEngine.EventSystems;

public class Instantiate : MonoBehaviour, IEventSystemHandler
{
    [SerializeField]
    public GameObject myModel;

    // Start is called before the first frame update
    void Start()
    {
        if (myModel != null) {
            Destroy(myModel);
        }
    }

    // Update is called once per frame
    void Update()
    {

    }

    // This method is called from Flutter
    public void InstantiateModel(String modelName)
    {
        if (myModel == null) {
            myModel = Instantiate(Resources.Load("Prefabs/" + modelName)) as GameObject;
            myModel.name = modelName;
            UnityMessageManager.Instance.SendMessageToFlutter("Instantiated the model: " + modelName);
        }
    }
}
