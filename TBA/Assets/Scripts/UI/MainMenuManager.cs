using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.SceneManagement;
using UnityEngine.UI;

public class MainMenuManager : MonoBehaviour
{

    public GameObject mainMenu;

    public Image loadingProgress;

    // Start is called before the first frame update
    void Start()
    {
        
    }

    // Update is called once per frame
    void Update()
    {
        
    }

    public void PlayGame(){
        SceneManager.LoadScene("Demo01");
    }

    public void QuitGame(){
        Application.Quit();
    }

    public void LoadLevel(int sceneIndex)
    {
        StartCoroutine(LoadAsynchronously(sceneIndex));
    }

    IEnumerator LoadAsynchronously(int sceneIndex)
    {
        AsyncOperation asyncOperation = SceneManager.LoadSceneAsync(sceneIndex);
        //loadingProgress.SetActive(true)
        asyncOperation.allowSceneActivation = false;
        
        while (!asyncOperation.isDone)
        {
            float progress = Mathf.Clamp01(asyncOperation.progress / .9f);
            loadingProgress.fillAmount = progress;
            if (asyncOperation.progress >= .9f)
            {
                asyncOperation.allowSceneActivation = true;
            }
            yield return null;
        }
    }
    
    
}
