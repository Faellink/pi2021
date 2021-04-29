using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.UI;
using UnityEngine.SceneManagement;
using TMPro;

public class GameManager : MonoBehaviour
{

    public GameObject scoreObject;

    public GameObject deathScreen;

    public TextMeshProUGUI scoreText;

    public TextMeshProUGUI[] menuScore;

    public GameObject gameUI;

    public static bool deathOn;

    public static int  enemiesCounter;

    public static bool canSpawnEnemies;

    public int spanedEnemies;

    public int numberofEnemies;

    public Animator scoreAnim;

    public static float score;

    public float lastScore;

    // Start is called before the first frame update
    void Start()
    {
        scoreObject = GameObject.FindGameObjectWithTag("Score");
        scoreText = scoreObject.GetComponent<TextMeshProUGUI>();
        scoreAnim = scoreObject.GetComponent<Animator>();
        score = 0;
        lastScore = score;
        scoreText.text = "";
        deathOn = false;
    }

    // Update is called once per frame
    void Update()
    {

        //numberofEnemies = GameObject.FindGameObjectsWithTag("Enemy").Length;

        Score();
        foreach (TextMeshProUGUI menuScoreText in menuScore)
        {
            menuScoreText.text = scoreText.text;
        }
        ScoreAnimation();
        DeathMenu();
        //spanedEnemies = numberofEnemies;
        //Debug.Log(enemiesCounter);

        spanedEnemies = enemiesCounter;
        CanSpawn();
    }

    void Score()
    {
        scoreText.text = score.ToString();
    }

    void CanSpawn(){
        if(enemiesCounter <= 100){
            canSpawnEnemies = true;
        }else if(enemiesCounter >100){
            canSpawnEnemies = false;
        }
    }

    void ScoreAnimation()
    {
        if (score > lastScore)
        {
            lastScore = score;
            scoreAnim.SetTrigger("ScoreUP");
        }
        else if (score <= lastScore)
        {
            scoreAnim.SetTrigger("ScoreIDLE");
        }
    }

    void DeathMenu()
    {
        if (PlayerController.playerDied == true)
        {
            deathScreen.SetActive(true);
            gameUI.SetActive(false);
            Cursor.lockState = CursorLockMode.None;
            Cursor.visible = true;
            Time.timeScale = 0f;
            //Debug.Log("é pra morrer");
            deathOn = true;
        }
    }

    public void TryAgain()
    {
        SceneManager.LoadScene("Demo01");
        Time.timeScale = 1f;
        //Pause.isPaused = false;
    }

    public void QuitToMainMenu(){
        SceneManager.LoadScene("Menu");
    }

    public void QuitGame()
    {
        Application.Quit();
    }
}
