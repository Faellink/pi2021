using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.UI;

public class Pause : MonoBehaviour
{

    public GameObject pauseMenu;
    public GameObject quitMenu;

    public GameObject gameUI;
    public static bool isPaused;

    // Start is called before the first frame update
    void Start()
    {
        isPaused = false;
        Time.timeScale = 1f;
    }

    // Update is called once per frame
    void Update()
    {

        if (GameManager.deathOn == false)
        {
            if (Input.GetKeyDown(KeyCode.P) || Input.GetKeyDown(KeyCode.Escape))
            {
                if (isPaused == true)
                {
                    Resume();
                    quitMenu.SetActive(false);
                }
                else
                {
                    Paused();
                }
            }
        }


        if (isPaused)
        {
            gameUI.SetActive(false);
        }
        else
        {
            gameUI.SetActive(true);
        }

    }
    void Paused()
    {
        pauseMenu.SetActive(true);
        Cursor.lockState = CursorLockMode.Confined;
        Time.timeScale = 0f;
        isPaused = true;
    }
    public void Resume()
    {
        Debug.Log("resume");
        pauseMenu.SetActive(false);
        Cursor.lockState = CursorLockMode.Locked;
        Time.timeScale = 1f;
        isPaused = false;
    }

    public void Quit()
    {

    }



}
