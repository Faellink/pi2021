using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.UI;
using TMPro;

public class GameManager : MonoBehaviour
{

    public GameObject scoreObject;

    public TextMeshProUGUI scoreText;

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
    }

    // Update is called once per frame
    void Update()
    {
        Score();
        ScoreAnimation();
    }

    void Score(){
        scoreText.text =  score.ToString();
    }

    void ScoreAnimation(){
        if(score > lastScore){
            lastScore = score;
            scoreAnim.SetTrigger("ScoreUP");
        }else if(score <= lastScore){
            scoreAnim.SetTrigger("ScoreIDLE");
        }
    }
}
