using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class PlayerMovement : MonoBehaviour
{
    public CharacterController controller;
    [HideInInspector] public float speed = 4f;
    [HideInInspector] public float sprintSpeed = 1.5f;
    [HideInInspector] public float gravity = -20f;
    [HideInInspector] public float jumpHeight = 1.25f;
    [HideInInspector] public float groundDistance = 0.4f;
    Vector3 velocity;
    void Start()
    {

    }

    void Update()
    {
        if (controller.isGrounded && velocity.y < 0)
        {
            velocity.y = -2f;
        }

        float x = Input.GetAxis("Horizontal");
        float z = Input.GetAxis("Vertical");

        Vector3 move = transform.right * x + transform.forward * z;
        velocity.y += gravity * Time.deltaTime;

        if (Input.GetKey(KeyCode.LeftControl) && controller.isGrounded)
        {
            move *= sprintSpeed;
        }

        if (Input.GetButton("Jump") && controller.isGrounded)
        {
            velocity.y = Mathf.Sqrt(jumpHeight * -2f * gravity);
        }

        controller.Move(move * speed * Time.deltaTime);
        controller.Move(velocity * Time.deltaTime);
    }
}