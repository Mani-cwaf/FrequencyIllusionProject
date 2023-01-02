using UnityEngine;

public class PlayerMovement : MonoBehaviour
{
    CharacterController controller;
    Transform cameraBody;
    float speed = 1.5f;
    float sprintEffect = 1.5f;
    float gravity = -7f;
    float jump = 0.9f;
    Vector3 velocity;
    float mouseSensitivity = 1.3f;
    float xRotation = 0f;

    private void Start() {
        Cursor.lockState = CursorLockMode.Locked;
        controller = transform.GetComponent<CharacterController>();
        cameraBody = transform.GetChild(0);
    }

    void Update()
    {
        float MouseX = Input.GetAxis("Mouse X") * mouseSensitivity;
        float MouseY = Input.GetAxis("Mouse Y") * mouseSensitivity;
        float x = Input.GetAxis("Horizontal");
        float z = Input.GetAxis("Vertical");

        Vector3 move = transform.right * x + transform.forward * z;

        if(Input.GetButton("Jump") && controller.isGrounded)
        {
            velocity.y = Mathf.Sqrt(jump * -2f * gravity);
        }
        if(Input.GetKey(KeyCode.LeftShift))
        {
            move *= sprintEffect;
        }

        controller.Move(move * speed * Time.deltaTime);

        velocity.y += gravity * Time.deltaTime;

        controller.Move(velocity * Time.deltaTime);

        xRotation -= MouseY;
        xRotation = Mathf.Clamp(xRotation, -90f, 90f);

        cameraBody.localRotation = Quaternion.Euler(xRotation, 0f, 0f);
        transform.Rotate(Vector3.up * MouseX);
    }
}